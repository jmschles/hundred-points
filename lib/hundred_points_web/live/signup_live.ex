defmodule HundredPointsWeb.SignupLive do
  use Phoenix.LiveView

  def render(%{username: _username} = assigns) do
    ~L"""
    <%= live_render(@socket, HundredPointsWeb.GameLive, session: %{"username" => @username}, id: "game") %>
    """
  end

  def render(assigns) do
    ~L"""
    <div class="">
      <div>
        <form action="#" method="post" phx-submit="save"><input name="_csrf_token" type="hidden" value="BUw_G3cRHxxMFwwpezA5NFJUaSURWjUkO6VoDYoO5tcKBihzec0GYiSe">
          <label for="user">Hi! What's your name?</label>
          <input type="text" name="user" id="user">
          <%= if @notice do %>
            <p><em><%= @notice %></em></p>
          <% end %>

          <button type="submit">Let's play!</button>
        </form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, notice: nil)}
  end

  def handle_event("save", %{"user" => username}, socket) do
    case validate(username) do
      {:error, error} ->
        {:noreply, assign(socket, notice: error)}

      {:ok, username} ->
        {:noreply, assign(socket, username: username)}
    end
  end

  defp validate(username) do
    case String.length(username) do
      n when n < 3 ->
        {:error, "Username must be at least 3 characters"}

      n when n > 24 ->
        {:error, "Username may not exceed 24 characters"}

      _ ->
        {:ok, username}
    end
  end
end
