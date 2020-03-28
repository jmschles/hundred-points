defmodule HundredPointsWeb.SignupLive do
  use Phoenix.LiveView

  def render(%{user: _user} = assigns) do
    ~L"""
    <%= live_render(@socket, HundredPointsWeb.GameLive, session: %{"user" => @user}, id: "game") %>
    """
  end

  def render(assigns) do
    ~L"""
    <div class="signup">
      <div>
        <form action="#" method="post" phx-submit="save">
          <input name="_csrf_token" type="hidden" value="FIXME">
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
    case HundredPoints.GameServer.add_player(username) do
      {:error, error} ->
        {:noreply, assign(socket, notice: error)}

      {:ok, user} ->
        {:noreply, assign(socket, user: user)}
    end
  end
end
