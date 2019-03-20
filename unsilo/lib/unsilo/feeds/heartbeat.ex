defmodule Unsilo.Feeds.Heartbeat do
  defstruct target: nil,
            looping: false

  use GenServer

  @retention Application.get_env(:unsilo, Unsilo.Feeds.Heartbeat)[:delete_retention]

  alias Unsilo.Feeds
  alias Unsilo.Feeds.Feed, as: UnsiloFeed
  alias FeederEx.Feed, as: FeederExFeed
  alias Unsilo.Feeds.Heartbeat
  alias Unsilo.Feeds.River
  alias Unsilo.Feeds.Story

  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %Heartbeat{}, name: Heartbeat)
  end

  def force_beat(%River{} = river) do
    GenServer.cast(__MODULE__, {:force_beat, river})
  end

  def init(state) do
    HTTPoison.start()
    {:ok, start_looping(state)}
  end

  def handle_info(:tick, state) do
    state =
      Feeds.list_feeds()
      |> scan_feeds(state)
      |> start_looping

    Feeds.cull_deleted_stories(@retention)

    {:noreply, state}
  end

  def handle_cast({:force_beat, river}, state) do
    state =
      Unsilo.Feeds.list_feeds(river)
      |> scan_feeds(state, force: true)

    {:noreply, state}
  end

  defp scan_feeds(feeds, state, opts \\ [])

  defp scan_feeds([], state, _opts) do
    state
  end

  defp scan_feeds([first | rest], state, opts) do
    scan_feed(first, opts)
    scan_feeds(rest, state, opts)
  end

  defp scan_feed(%UnsiloFeed{last_poll: last_poll, sleep_time: sleep_time} = feed, opts) do
    cond do
      is_nil(last_poll) ->
        fetch_stories(feed)

      is_nil(sleep_time) ->
        fetch_stories(feed)

      sleep_expired?(feed) ->
        fetch_stories(feed)

      Keyword.get(opts, :force, false) ->
        fetch_stories(feed)
    end
  end

  defp fetch_stories(%UnsiloFeed{url: url} = feed) do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url),
         {:ok, %FeederExFeed{entries: entries}, _} <- parse_body_data(body, url),
         {:ok, new_stories} <- create_stories([], entries, feed) do
      Feeds.set_last_poll(feed)
      new_stories
    else
      {:error, :empty_data_parse} ->
        Logger.error("empty data returned by #{url}")
        []

      {:fatal_error, _, 'whitespace expected', [], _} ->
        Logger.error("parsing error for #{url}")
        []

      error ->
        Logger.error("unknown error: #{inspect(error)} for #{url}")
        []
    end
  end

  defp parse_body_data("", _url) do
    {:error, :empty_data_parse}
  end

  defp parse_body_data(data, _url) do
    FeederEx.parse(data)
  end

  defp create_stories(acc, [], _feed) do
    acc
  end

  defp create_stories(acc, [first | rest], %UnsiloFeed{} = feed) do
    stories =
      first
      |> Story.params_from_entry()
      |> Feeds.create_story_if_recent(feed)
      |> case do
        {:ok, story} ->
          create_stories([story | acc], rest, feed)

        {:err, :outdated} ->
          create_stories(acc, rest, feed)

        {:error, %{errors: [remote_id: {"has already been taken", _}]}} ->
          create_stories(acc, rest, feed)

        {:error, changeset} ->
          Logger.error(inspect(changeset.errors))
          create_stories(acc, rest, feed)
      end

    {:ok, stories}
  end

  defp sleep_expired?(%UnsiloFeed{last_poll: last_poll, sleep_time: sleep_time}) do
    last_poll
    |> Timex.shift(second: sleep_time)
    |> Timex.after?(DateTime.utc_now())
  end

  defp start_looping(state = %{}) do
    Process.send_after(self(), :tick, 5 * 60 * 1000)

    %{state | looping: true}
  end
end
