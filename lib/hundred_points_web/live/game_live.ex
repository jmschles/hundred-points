defmodule HundredPointsWeb.GameLive do
  use Phoenix.LiveView

  @channel_name "game"

  def render(assigns) do
    ~L"""
    <div class="inner-container">
      <%= if @user_data.username in Enum.map(@game_state.players, & &1.username) do %>
        <div class="header">
          <div class="nav">
            <span class="nav-item">Hey <strong><%= @user_data.username %></strong>!! You look nice today.</span>
            <span class="nav-item">Game status: <strong><%= @game_state.phase %></strong></span>
            <span class="nav-item">Cards in reserve: <%= @game_state.card_count %> <em>(don't go below zero!)</em></span>
            <%= if @game_state.active_player && @game_state.active_player.username == @user_data.username do %>
              <span class="nav-item"><strong>YOUR TURN!!</strong></span>
            <% end %>
          </div>
        </div>

        <div class="players">
          <h3>Who's Playing</h3>
          <ul>
            <%= for player <- @game_state.players do %>
              <li>
                <%= player.username %>
                <%= if player.moderator do %>
                  <strong>(M)</strong>
                <% end %>
              </li>
            <% end %>
          </ul>
        </div>

        <div class="game-area">
          <div class="main-game-area">
            <%= if @game_state.phase == :preparation do %>
              <h3>Preparation phase. Make cards until the game starts!</h3>
            <% end %>

            <%= if @game_state.phase == :game_over do %>
              <h3>Woohoo, <%= @game_state.winner.username %> wins! Yaaaay, <%= @game_state.winner.username %>!!!</h3>
            <% end %>

            <%= if @game_state.phase == :playing do %>
              <div class="active-card">
                <div class="active-card-action">
                  <span class="dark-gray">Action: </span><%= @game_state.active_card.action %>
                </div>
                <div class="active-card-points">
                  <span class="dark-gray">Points: </span><%= @game_state.active_card.points %>
                </div>
              </div>
              <%= if @game_state.active_player.username == @user_data.username do %>
                <div class="player-actions">
                  <button phx-click="pass_turn">Skip turn</button>
                  <div class="dropdown">
                    <button>Pass to...</button>
                    <div class="dropdown-content">
                      <%= for player <- @game_state.players do %>
                        <%= if player.username != @user_data.username do %>
                          <a href="#" phx-click="pass_to_player" phx-value-username="<%= player.username %>"><%= player.username %></a>
                        <% end %>
                      <% end %>
                    </div>
                  </div>
                  <button phx-click="action_completed">I did it, gimme points!</button>
                </div>
              <% end %>
            <% end %>
          </div>

          <%= if @game_state.phase in [:preparation, :playing, :paused] do %>
            <div class="card-maker">
              <hr>
              <h3>Make a new card!</h3>
              <form action="#" method="post" phx-submit="save_card">
                <div>
                  <input name="_csrf_token" type="hidden" value="<%= Plug.CSRFProtection.get_csrf_token() %>">
                  <div class="action-description-field">
                    <label for="action">Action description:</label>
                    <input type="text" name="action" id="action">
                  </div>

                  <div class="points-field">
                    <label for="points">Point value</label>
                    <input type="text" name="points" id="points">
                  </div>

                  <div class="card-submit">
                    <button type="submit">Add card!</button>
                  </div>
                </div>

                <%= if @notice do %>
                  <div class="card-notice"><em><%= @notice %></em></div>
                <% end %>
              </form>
            </div>
          <% end %>
        </div>

        <div class="standings">
          <%= if @game_state.phase in [:playing, :game_over] do %>
            <h3>Scores</h3>
            <table>
              <tr>
                <th>Name</th>
                <th>Score</th>
              </tr>
              <%= for player <- @game_state.standings do %>
                <tr>
                  <td><%= player.username %></td>
                  <td><%= player.score %></td>
                </tr>
              <% end %>
            </table>
          <% end %>
        </div>

        <div class="footer">
          <%= if Enum.find(@game_state.players, & &1.moderator).username == @user_data.username do %>
            <div class="footer-header"><strong>You are the moderator!</strong></div>
            <div class="nav">
              <div class="footer-col1 nav-item dropdown">
                <button>Assign moderator to...</button>
                <div class="dropdown-content dropdown-footer">
                  <%= for player <- @game_state.players do %>
                    <%= if !player.moderator do %>
                      <a class="dropdown-footer" href="#" phx-click="reassign_moderator" phx-value-username="<%= player.username %>"><%= player.username %></a>
                    <% end %>
                  <% end %>
                </div>
              </div>
              <%= if @game_state.phase == :playing do %>
                <div class="footer-col2 nav-item">
                  <button class="orange-bg" phx-click="pass_turn">Skip player's turn</button>
                </div>
              <% end %>
              <%= if @game_state.phase == :preparation do %>
                <div class="footer-col3 nav-item">
                  <button phx-click="start_game">Start the game!</button>
                </div>
              <% end %>
              <div class="footer-col3 nav-item">
                <%= if @game_state.phase == :game_over do %>
                  <button phx-click="restart_game">Restart the game!</button>
                <% end %>
                <%= if @game_state.phase in [:playing, :paused] do %>
                  <button class="red-bg" phx-click="restart_game">Reset game (destructive!)</button>
                <% end %>
              </div>
              <div class="footer-col4 nav-item dropdown">
                <button class="red-bg">Kick player...</button>
                <div class="dropdown-content dropdown-footer">
                  <%= for player <- @game_state.players do %>
                    <%= if !player.moderator do %>
                      <a class="dropdown-footer" href="#" phx-click="kick_player" phx-value-username="<%= player.username %>"><%= player.username %></a>
                    <% end %>
                  <% end %>
                </div>
              </div>
            </div>
          <% else %>
            <div class="footer-col1 nav">
              <div class="nav-wrapper">
                <button phx-click="reassign_moderator" phx-value-username="<%= @user_data.username %>">Become the moderator</button>
              </div>
            </div>
          <% end %>
        </div>
      <% else %>
        <div class="game-area">
          <h3>Oh no! Looks like you've disconnected. Refresh the page to rejoin.</h3>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(
        _params,
        %{"user" => user_data},
        socket
      ) do
    broadcast_update()
    HundredPointsWeb.Endpoint.subscribe(@channel_name)

    {:ok,
     assign(socket,
       user_data: user_data,
       game_state: HundredPoints.GameServer.get_state(),
       notice: nil
     )}
  end

  def handle_event("save_card", params, socket) do
    case HundredPoints.GameServer.add_card(params) do
      {:error, error} ->
        {:noreply, assign(socket, notice: error)}

      {:ok, card_count} ->
        broadcast_update()

        {:noreply,
         assign(
           socket,
           notice: "Card added",
           game_state: %{socket.assigns.game_state | card_count: card_count}
         )}
    end
  end

  def handle_event("start_game", _params, %{assigns: %{game_state: %{card_count: 0}}} = socket) do
    {:noreply, assign(socket, notice: "Need cards to start playing. Make some!")}
  end

  def handle_event("start_game", _params, socket) do
    updated_state = HundredPoints.GameServer.begin_play()
    broadcast_update()

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_event("restart_game", _params, socket) do
    updated_state = HundredPoints.GameServer.restart_game()
    broadcast_update()

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_event("pass_turn", _params, socket) do
    updated_state = HundredPoints.GameServer.pass_turn()
    broadcast_update()

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_event(
        "action_completed",
        _params,
        %{assigns: %{game_state: %{card_count: 0}}} = socket
      ) do
    {:noreply, assign(socket, notice: "Uhoh! No more cards! Add some cards to continue.")}
  end

  def handle_event("action_completed", _params, socket) do
    updated_state = HundredPoints.GameServer.action_performed()
    broadcast_update()

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_event("pass_to_player", %{"username" => username}, socket) do
    updated_state = HundredPoints.GameServer.pass_to_player(username)
    broadcast_update()

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_event("reassign_moderator", %{"username" => username}, socket) do
    updated_state = HundredPoints.GameServer.reassign_moderator(username)
    broadcast_update()

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_event("kick_player", %{"username" => username}, socket) do
    updated_state = HundredPoints.GameServer.kick_player(username)
    broadcast_update()

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_info(%{event: "state_update"}, socket) do
    {:noreply, assign(socket, game_state: HundredPoints.GameServer.get_state())}
  end

  defp broadcast_update do
    HundredPointsWeb.Endpoint.broadcast_from(self(), @channel_name, "state_update", %{})
  end
end
