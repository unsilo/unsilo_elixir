defmodule UnsiloWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: UnsiloWeb

      import Plug.Conn
      import UnsiloWeb.Gettext
      import Canary.Plugs
      alias UnsiloWeb.Router.Helpers, as: Routes
      import UnsiloWeb.Controllers.ActionBtnHelpers
      import Phoenix.LiveView.Controller
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/unsilo_web/templates",
        namespace: UnsiloWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, get_flash: 1, get_flash: 2, view_module: 1]

      import Phoenix.LiveView,
        only: [live_render: 2, live_render: 3, live_link: 1, live_link: 2]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import UnsiloWeb.ErrorHelpers
      import UnsiloWeb.Gettext
      alias UnsiloWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import UnsiloWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
