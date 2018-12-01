defmodule UnsiloWeb.LayoutView do
  use UnsiloWeb, :view

  def page_description(_conn) do
    "personal cloud"
  end

  def logged_in?(%{assigns: %{current_user: nil}}), do: false
  def logged_in?(%{assigns: %{current_user: _}}), do: true
  def logged_in?(_), do: false

  def session_buttons(%{request_path: "/dashboard", assigns: %{current_user: user}} = conn) do
    if logged_in?(conn) do
      [
        content_tag(:a, "Account",
          class: "btn btn-outline-primary ml-3",
          href: "#{Routes.user_path(conn, :show, user)}"
        ),
        content_tag(:a, "Log Out",
          class: "btn btn-outline-success ml-3 action_btn",
          href: "#",
          "data-modal-delete-url": "#{Routes.session_path(conn, :delete, id: 1)}",
          "data-success-redirect-url": "#{Routes.page_path(conn, :index)}"
        )
      ]
    else
      content_tag(:a, "Log In",
        class: "btn btn-outline-primary ml-3",
        href: "#{Routes.session_path(conn, :new)}"
      )
    end
  end

  def tool_bar_btns(conn) do
    if logged_in?(conn) do
      [
        content_tag(:a, "Spots",
          class: "btn btn-outline-primary ml-3",
          href: "#{Routes.spot_path(conn, :index)}"
        )
      ]
    else
      []
    end
  end

  def permit_uninvited_signups? do
    Application.get_env(:unsilo, Unsilo.UserController)[:allow_signups]
  end

  def session_buttons(conn, _opts \\ []) do
    cond do
      logged_in?(conn) ->
        [
          content_tag(:a, "Dashboard",
            class: "btn btn-outline-primary ml-3",
            href: "#{Routes.dashboard_path(conn, :index)}"
          ),
          content_tag(:a, "Log Out",
            class: "btn btn-outline-success ml-3 action_btn",
            href: "#",
            "data-modal-delete-url": "#{Routes.session_path(conn, :delete, id: 1)}",
            "data-success-redirect-url": "#{Routes.page_path(conn, :index)}"
          )
        ]

      permit_uninvited_signups?() ->
        [
          content_tag(:a, "Create Account",
            class: "btn btn-outline-primary ml-3 action_btn",
            href: "#",
            "data-modal-src-url": "#{Routes.user_path(conn, :new)}",
            "data-success-redirect-url": "#{Routes.dashboard_path(conn, :index)}"
          ),
          content_tag(:a, "Log In",
            class: "btn btn-outline-success ml-3 action_btn",
            href: "#",
            "data-modal-src-url": "#{Routes.session_path(conn, :new)}",
            "data-success-redirect-url": "#{Routes.dashboard_path(conn, :index)}"
          )
        ]

      true ->
        [
          content_tag(:a, "Log In",
            class: "btn btn-outline-success ml-3 action_btn",
            href: "#",
            "data-modal-src-url": "#{Routes.session_path(conn, :new)}",
            "data-success-redirect-url": "#{Routes.dashboard_path(conn, :index)}"
          )
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

  def page_heading(conn) do
    try do
      apply(view_module(conn), :page_title, [conn])
    rescue
      _ ->
        case conn.assigns[:page_sub_title] do
          nil ->
            content_tag(
              :a,
              Application.get_env(:unsilo, :app_domain),
              href: "/"
            )

          other ->
            [
              content_tag(:a, "#{Application.get_env(:unsilo, :app_domain)}", href: "/"),
              "/",
              content_tag(:a, other, href: "#{conn.assigns[:page_sub_title_url]}")
            ]
        end
    end
  end

  def new_item_button(conn) do
    case conn.assigns[:new_item_url] do
      nil ->
        ""

      other ->
        content_tag(:a, "new",
          class: "btn btn-outline-success action_btn",
          href: "#",
          "data-modal-src-url": "#{other}",
          "data-success-dom-dest": "#spot_list"
        )
    end
  end
end
