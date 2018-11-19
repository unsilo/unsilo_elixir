defmodule UnsiloWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :unsilo,
    error_handler: UnsiloWeb.Auth.AuthErrorHandler,
    module: UnsiloWeb.Auth.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  plug Guardian.Plug.LoadResource, allow_blank: true
  plug UnsiloWeb.Plugs.AssignUser
end
