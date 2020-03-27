defmodule HundredPointsWeb.PageController do
  use HundredPointsWeb, :controller
  import Phoenix.LiveView.Controller

  def index(conn, _) do
    live_render(conn, HundredPointsWeb.SignupLive, session: %{})
  end
end
