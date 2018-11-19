defmodule UnsiloWeb.LayoutView do
  use UnsiloWeb, :view

  def page_description(_conn) do
    "personal cloud"
  end

  def logged_in?(%{user: nil}), do: false
  def logged_in?(%{user: _}), do: true
  def logged_in?(_), do: false

  def session_buttons(%{request_path: "/dashboard", user: user} = conn) do
    if logged_in?(conn) do
      [
        content_tag(:a, "Account", class: "btn btn-outline-primary ml-3", href: "#{Routes.user_path(conn, :show, user)}"),
        link("Log Out", to: "#{Routes.session_path(conn, :delete)}", class: "btn btn-outline-primary ml-3", method: :delete)
      ]
    else
      content_tag(:a, "Log In", class: "btn btn-outline-primary ml-3", href: "#{Routes.session_path(conn, :new)}")
    end
  end




  def permit_uninvited_signups?, do: true

  def session_buttons(conn, _opts \\ []) do
    cond do
     logged_in?(conn) ->
      [
        content_tag(:a, "Dashboard", class: "btn btn-outline-primary ml-3", href: "#{Routes.dashboard_path(conn, :index)}"),
        content_tag(:a, "Log Out", class: "btn btn-outline-primary ml-3", href: "#{Routes.session_path(conn, :delete)}")
      ]
    permit_uninvited_signups?() ->
      [
        content_tag(:a, "Create Account", class: "btn btn-outline-primary ml-3 action_btn",
                                  href: "#", 
                                  "data-modal-src-url": "#{Routes.user_path(conn, :new)}",
                                  "data-success-redirect-url": "#{Routes.dashboard_path(conn, :index)}"),
        content_tag(:a, "Log In", class: "btn btn-outline-success ml-3 action_btn",
                                  href: "#", 
                                  "data-modal-src-url": "#{Routes.session_path(conn, :new)}",
                                  "data-success-redirect-url": "#{Routes.dashboard_path(conn, :index)}")
      ]
    true ->
      [
        content_tag(:a, "Log In", class: "btn btn-outline-success ml-3 action_btn",
                                  href: "#", 
                                  "data-modal-src-url": "#{Routes.session_path(conn, :new)}",
                                  "data-success-redirect-url": "#{Routes.dashboard_path(conn, :index)}")
      ]

    end
  end

  def page_title(conn) do
    try do
      apply(view_module(conn), :page_title, [conn])
    rescue
      _ ->
        case conn.assigns[:page_title] do
          nil ->
            Application.get_env(:unsilo, :app_domain)
          other ->
            "#{Application.get_env(:unsilo, :app_domain)} - #{other}"
        end
    end
  end
end
