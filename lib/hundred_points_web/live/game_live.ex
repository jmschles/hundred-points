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
        <h4>Make a card!</h4>
        <form action="#" method="post" phx-submit="save_card">
        <input name="_csrf_token" type="hidden" value="FIXME">
          <label for="action">Action description:</label>
          <input type="text" name="action" id="action">

          <label for="points">Point value</label>
          <input type="text" name="points" id="points">

          <%= if @notice do %>
            <p><em><%= @notice %></em></p>
          <% end %>

          <button type="submit">Add card!</button>
        </form>
      </div>
      <div>
        <h4>Scores</h4>
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
       players: HundredPoints.UserServer.all_users(),
       notice: nil
     )}
  end

  def handle_info(%{event: "player_joined"}, socket) do
    {:noreply, assign(socket, players: HundredPoints.UserServer.all_users())}
  end

  def handle_event("save_card", params, socket) do
    case HundredPoints.CardServer.add_card(params) do
      {:error, error} ->
        {:noreply, assign(socket, notice: error)}

      {:ok, _card} ->
        {:noreply, assign(socket, notice: "Card added")}
    end
  end
end
