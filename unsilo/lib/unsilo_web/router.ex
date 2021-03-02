defmodule UnsiloWeb.Router do
  use UnsiloWeb, :router

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(Phoenix.LiveView.Flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:put_layout, {UnsiloWeb.LayoutView, :app})
  end

  pipeline :api do
    plug(CORSPlug, origin: "*")
  end

  pipeline :domain_spot do
    plug(UnsiloWeb.Plugs.DomainSpot)
  end

  pipeline :browser_auth do
    plug(UnsiloWeb.Auth.Pipeline)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :ensure_admin do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  scope "/", UnsiloWeb do
    pipe_through([:browser, :api])

    resources("/subscriber", SubscriberController, only: [:new, :create])
    options("/subscriber", SubscriberController, :options)
  end

  scope "/", UnsiloWeb do
    pipe_through([:browser, :domain_spot, :browser_auth])
    resources("/user", UserController, only: [:new, :create])
  end

  scope "/", UnsiloWeb do
    pipe_through([:browser, :browser_auth, :ensure_auth])

    resources("/subscriber", SubscriberController, only: [:delete])
    resources("/spots", SpotController)

    resources("/rivers", RiverController, except: [:index, :show])

    resources("/locations", LocationController, except: [:index, :show]) do
    end

    live("/locations/:location_id/nest", NestShowLive, session: [:location_id])

    resources("/rivers", RiverController, except: [:index, :show])
    resources("/feeds", FeedController, only: [:new, :create, :delete])
    resources("/stories", StoryController, only: [:index, :update])

    resources("/dashboard", DashboardController, only: [:index])
    resources("/user", UserController, only: [:edit, :show, :update, :delete])
    resources("/devices", DeviceController, except: [:index])

    delete("/session", SessionController, :delete)
  end

  scope "/", UnsiloWeb do
    pipe_through([:browser, :domain_spot, :browser_auth])

    get("/", PageController, :index)

    get("/session", SessionController, :new)
    post("/session", SessionController, :create)
    resources("/rivers", RiverController, only: [:index, :show])

    resources("/locations", LocationController, only: [:index, :show]) do
    end
  end

  scope "/", UnsiloWeb do
    pipe_through([:browser, :browser_auth, :ensure_admin])

    resources("/user", UserController, only: [:index])
  end

  scope "/", UnsiloWeb do
    pipe_through([:browser, :domain_spot])

    get("/*path", PageController, :index)
  end
end
