defmodule UnsiloWeb.SonosLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
      <div id="sonos_row" class="row">
        Hi
      </div>
    """
  end

  def mount(sess, socket) do
    IO.inspect(sess)
    {:ok, _pid} = Registry.register(Sonex, "devices", [])

    {:ok, socket}
  end
end
