defmodule UnsiloWeb.NestShowLive do
  defmodule ShowData do
    defstruct location_id: "", interval: nil, type: nil, start: nil, finish: nil, devices: []
  end

  use Phoenix.HTML
  use Phoenix.LiveView

  alias Unsilo.Places.Series.NestHeat

  @allowed_intervals ~w(minute hour day week month)

  def render(assigns) do
    Phoenix.View.render(UnsiloWeb.DeviceView, "nest_show_live.html", assigns)
  end

  def mount(%{location_id: location_id}, socket) do
    devices =
      Enum.reduce(NestHeat.get_uuids(), %{}, fn {uid, count}, acc ->
        Map.put(acc, uid, %{count: count, enabled: true})
      end)

    socket =
      socket
      |> assign(
        show_data: %ShowData{
          location_id: location_id,
          start: NestHeat.get_earliest(),
          finish: NestHeat.get_latest(),
          interval: "week",
          devices: devices,
          type: :line
        }
      )

    {:ok, decorate_socket(socket)}
  end

  def handle_info(an, state) do
    IO.inspect(an, label: "the unknown handle info")
    {:noreply, state}
  end

  def handle_event(
        "change_interval",
        %{"interval" => interval, "start" => start, "finish" => finish} = prms,
        %{assigns: %{show_data: show_data}} = socket
      ) do
    IO.inspect(prms)
    show_data =
      show_data
      |> assign_show_data(:interval, prms)
      |> assign_show_data(:start_finish, prms)
      |> assign_show_data(:devices, prms)

    socket = assign(socket, :show_data, show_data)

    {:noreply, decorate_socket(socket)}
  end

  defp assign_show_data(%{devices: devices} = show_data, :devices, prms) do
    uuids = for {"ucheck-" <> uuid, value} <- prms do
      uuid
    end |> IO.inspect(label: "th on checkboxes")

    %{show_data | devices: Enum.map(devices, &parse_uuids(&1, uuids))} |> IO.inspect
  end

  defp assign_show_data(show_data, :start_finish, %{"start" => start, "finish" => finish}) do
    {:ok, start} = Timex.parse!(start, "%Y-%m-%d", :strftime) |> DateTime.from_naive("Etc/UTC")
    {:ok, finish} = Timex.parse!(finish, "%Y-%m-%d", :strftime) |> DateTime.from_naive("Etc/UTC")

    {start, finish} =
      if Timex.after?(finish, start) do
        {start, finish}
      else
        {finish, start}
      end

    %{show_data | start: start, finish: finish} |> IO.inspect(label: "inside assign_show_data")
  end

  defp assign_show_data(show_data, :interval, %{"interval" => interval}) when interval in @allowed_intervals,
    do: %{show_data | interval: interval}

  defp assign_show_data(socket, show_data, _key, _value), do: show_data

  defp parse_uuids({uuid, dev}, devices) do
    dev = %{dev | enabled: Enum.member?(devices, uuid)}
    {uuid, dev}
  end

  defp decorate_socket(%{assigns: %{show_data: show_data}} = socket) do
    socket
    |> assign(show_data: show_data)
    |> assign(chart_data: calc_chart_data(show_data) |> Jason.encode!())
    |> assign(unload_charts: unloaded_uuids(show_data) |> Jason.encode!())
  end

  defp calc_chart_data(%{devices: devices} = state) do
    %{
      results: [
        %{
          series: chart_data
        }
      ]
    } =
      NestHeat.query(
        "SELECT MEAN(\"avg_temp\") FROM \"nest_thermostat\" WHERE #{uuid_grouping(state)} AND #{time_grouping(state)} GROUP BY #{
          interval_grouping(state)
        }, \"uuid\""
        |> IO.inspect()
      )

    ts = Enum.reduce(chart_data, [], &accumulate_timestamps(&1, &2)) |> Enum.uniq() |> Enum.sort()

    tmps = Enum.reduce(chart_data, %{}, &collate_temps(&1, &2, ts))
    tmps = Map.put(tmps, "x", ts)


    unloads = for {uuid, %{enabled: false}} <- devices do
      uuid
    end

    %{
      columns: Enum.reduce(tmps, [], fn {k, v}, acc -> [[k | v] | acc] end),
      unload: unloads
    }
  end

  defp interval_grouping(%{interval: "month"}), do: "time(4w)"
  defp interval_grouping(%{interval: "week"}), do: "time(1w)"
  defp interval_grouping(%{interval: "day"}), do: "time(1d)"
  defp interval_grouping(%{interval: "hour"}), do: "time(1h)"

  defp time_grouping(%{start: start, finish: finish}) do
    IO.inspect(start, label: "START")
    IO.inspect(finish, label: "FINISH")

    "time >= '#{Timex.format!(start, "{ISO:Extended}")}' AND time <= '#{
      Timex.format!(finish, "{ISO:Extended}")
    }'"
  end

  defp uuid_grouping(%{devices: devices}) do
    uuid_str = for {uuid, %{enabled: true}} <- devices do
      "\"uuid\" = '#{uuid}'"
    end
    |> Enum.join(" OR ")

    "(#{uuid_str})"
  end

  defp unloaded_uuids(%{devices: devices}) do
    uuids = for {uuid, %{enabled: false}} <- devices do
      uuid
    end
    |> IO.inspect(label: "uuid_str")

    uuids
  end

  defp accumulate_timestamps(%{values: values}, acc) do
    Enum.reduce(values, acc, fn [<<date::binary-size(10)>> <> "T" <> <<_ignore::binary>>, _temp],
                                acc ->
      [date | acc]
    end)
  end

  defp collate_temps(%{tags: %{uuid: uuid}, values: values}, acc, timestamps) do
    value_map =
      values
      |> Enum.reduce(%{}, fn [<<date::binary-size(10)>> <> "T" <> <<_ignore::binary>>, val],
                             acc ->
        Map.put(acc, date, val)
      end)

    value_list =
      Enum.reduce(timestamps, [], fn ts, acc -> [Map.get(value_map, ts, nil) | acc] end)

    Map.put(acc, uuid, value_list)
  end

  defp get_time_stamps() do
  end
end
