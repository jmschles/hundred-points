defmodule HundredPointsWeb.GameLive do
  use Phoenix.LiveView

  def render(%{username: _username} = assigns) do
    ~L"""
    <div class="">
      <div>
        Hey <%= @username %>!!
        Your score is <%= @score %>.
        <%= if @moderator do %>
          You are the moderator.
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_params, %{"user" => %{username: username, score: score, moderator: moderator}}, socket) do
    {:ok, assign(socket, username: username, score: score, moderator: moderator)}
  end
end
