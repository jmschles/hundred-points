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
      <div>
        <table>
          <tr>
            <td>Name</td>
            <td>Score</td>
          </tr>
          <%= for player <- @players do %>
            <tr>
              <td><%= player.username %></td>
              <td><%= player.score %></td>
            </tr>
          <% end %>
        </table>
      </div>
    </div>
    """
  end

  def mount(
        _params,
        %{"user" => %{username: username, score: score, moderator: moderator}},
        socket
      ) do
    HundredPointsWeb.Endpoint.broadcast_from(self(), "game", "player_joined", %{})
    HundredPointsWeb.Endpoint.subscribe("game")

    {:ok,
     assign(socket,
       username: username,
       score: score,
       moderator: moderator,
       players: HundredPoints.UserServer.all_users()
     )}
  end

  def handle_info(%{event: "player_joined"}, socket) do
    {:noreply, assign(socket, players: HundredPoints.UserServer.all_users())}
  end
end
