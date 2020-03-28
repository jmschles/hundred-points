defmodule HundredPointsWeb.GameLive do
  use Phoenix.LiveView

  @channel_name "game"

  def render(assigns) do
    ~L"""
    <div class="inner-container">
      <div class="header">
        <div class="nav">
          <span class="nav-item">Hey <strong><%= @user_data.username %></strong>!! You look nice today.</span>
          <span class="nav-item">Game status: <strong><%= @game_state.phase %></strong></span>
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
                  <button>Pass to... v</button>
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
        <% end %>
      </div>

      <div class="standings">
        <%= if @game_state.phase in [:playing, :game_over] do %>
          <h3>Scores</h3>
          <table>
            <tr>
              <td>Name</td>
              <td>Score</td>
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
        <%= if @user_data.moderator do %>
          <hr>
          <div class="nav">
            <span class="nav-item">You are the moderator!</span>
            <span class="nav-item">Assign moderator to... [WIP]</span>
            <%= if @game_state.phase == :preparation do %>
              <div class="nav-wrapper">
                <button phx-click="start_game">Start the game!</button>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
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
    case HundredPoints.CardServer.add_card(params) do
      {:error, error} ->
        {:noreply, assign(socket, notice: error)}

      {:ok, _card} ->
        {:noreply, assign(socket, notice: "Card added")}
    end
  end

  def handle_event("start_game", _params, socket) do
    updated_state = HundredPoints.GameServer.begin_play()
    broadcast_update()

    {:noreply, assign(socket, game_state: updated_state)}
  end

  def handle_event("pass_turn", _params, socket) do
    updated_state = HundredPoints.GameServer.pass_turn()
    broadcast_update()

    {:noreply, assign(socket, game_state: updated_state)}
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

  def handle_info(%{event: "state_update"}, socket) do
    {:noreply, assign(socket, game_state: HundredPoints.GameServer.get_state())}
  end

  defp broadcast_update do
    HundredPointsWeb.Endpoint.broadcast_from(self(), @channel_name, "state_update", %{})
  end
end
