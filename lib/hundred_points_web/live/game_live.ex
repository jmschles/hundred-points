defmodule HundredPointsWeb.GameLive do
  use Phoenix.LiveView

  def render(%{username: _username} = assigns) do
    ~L"""
    <div class="">
      <div>
        Hey <%= @username %>!!
      </div>
    </div>
    """
  end

  def mount(_params, %{"username" => username}, socket) do
    {:ok, assign(socket, username: username)}
  end
end
