defmodule HundredPoints.GameServer do
  use GenServer
  alias HundredPoints.Game

  def init(_initial_state) do
    {:ok, %Game{phase: :preparation, standings: [], players: [], card_count: 0}}
  end

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def restart_game do
    GenServer.call(__MODULE__, :restart_game)
  end

  def begin_play do
    GenServer.call(__MODULE__, :begin_play)
  end

  def add_player(username) do
    GenServer.call(__MODULE__, {:add_player, username})
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def pass_turn do
    GenServer.call(__MODULE__, :pass_turn)
  end

  def pass_to_player(username) do
    GenServer.call(__MODULE__, {:pass_to_player, username})
  end

  def reassign_moderator(username) do
    GenServer.call(__MODULE__, {:reassign_moderator, username})
  end

  def kick_player(username) do
    GenServer.call(__MODULE__, {:kick_player, username})
  end

  def action_performed do
    GenServer.call(__MODULE__, :action_performed)
  end

  def add_card(params) do
    GenServer.call(__MODULE__, {:add_card, params})
  end

  def handle_call(:restart_game, _from, state) do
    HundredPoints.UserServer.reset_scores()

    updated_state = %{
      state
      | active_card: nil,
        active_player: nil,
        winner: nil,
        standings: HundredPoints.UserServer.standings(),
        players: HundredPoints.UserServer.players_in_turn_order(),
        phase: :preparation
    }

    {:reply, updated_state, updated_state}
  end

  def handle_call(:begin_play, _from, state) do
    HundredPoints.UserServer.shuffle_players()
    HundredPoints.CardServer.shuffle_cards()

    updated_state = %{
      state
      | phase: :playing,
        active_player: HundredPoints.UserServer.next_active_player(),
        players: HundredPoints.UserServer.players_in_turn_order(),
        active_card: HundredPoints.CardServer.next_card(),
        card_count: state.card_count - 1,
        standings: HundredPoints.UserServer.standings()
    }

    {:reply, updated_state, updated_state}
  end

  def handle_call({:add_player, username}, _from, state) do
    case HundredPoints.UserServer.add_player(username) do
      {:ok, player} ->
        updated_state = %{
          state
          | standings: HundredPoints.UserServer.standings(),
            players: HundredPoints.UserServer.players_in_turn_order()
        }

        {:reply, {:ok, player}, updated_state}

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_call(:pass_turn, _from, state) do
    updated_state = %{
      state
      | active_player: HundredPoints.UserServer.next_active_player(),
        players: HundredPoints.UserServer.players_in_turn_order()
    }

    {:reply, updated_state, updated_state}
  end

  def handle_call({:pass_to_player, username}, _from, state) do
    chosen_player = HundredPoints.UserServer.select_active_player(username)

    updated_state = %{
      state
      | active_player: chosen_player,
        players: HundredPoints.UserServer.players_in_turn_order()
    }

    {:reply, updated_state, updated_state}
  end

  def handle_call({:reassign_moderator, username}, _from, state) do
    HundredPoints.UserServer.reassign_moderator(username)

    updated_state = %{
      state
      | players: HundredPoints.UserServer.players_in_turn_order()
    }

    {:reply, updated_state, updated_state}
  end

  def handle_call({:kick_player, username}, _from, state) do
    HundredPoints.UserServer.kick_player(username)

    case HundredPoints.UserServer.get_active_player() do
      nil ->
        # Last player has left, so go medieval and reset all
        HundredPoints.CardServer.clear_cards()
        reboot_state = %Game{phase: :preparation, standings: [], players: [], card_count: 0}
        {:reply, reboot_state, reboot_state}

      active_player ->
        updated_state = %{
          state
          | players: HundredPoints.UserServer.players_in_turn_order(),
            active_player: active_player,
            standings: HundredPoints.UserServer.standings()
        }

        {:reply, updated_state, updated_state}
    end
  end

  def handle_call(:action_performed, _from, %{active_card: %{points: points}} = state) do
    next_active_player = HundredPoints.UserServer.award_points(points)
    updated_standings = HundredPoints.UserServer.standings()

    updated_state =
      case winner(updated_standings) do
        nil ->
          %{
            state
            | active_card: HundredPoints.CardServer.next_card(),
              card_count: state.card_count - 1,
              active_player: next_active_player,
              standings: updated_standings,
              players: HundredPoints.UserServer.players_in_turn_order()
          }

        %HundredPoints.User{} = winner ->
          %{
            state
            | active_card: nil,
              active_player: nil,
              standings: updated_standings,
              phase: :game_over,
              winner: winner,
              players: HundredPoints.UserServer.players_in_turn_order()
          }
      end

    {:reply, updated_state, updated_state}
  end

  def handle_call({:add_card, params}, _from, state) do
    case HundredPoints.CardServer.add_card(params) do
      {:error, error} ->
        {:reply, {:error, error}, state}

      {:ok, card_count} ->
        {:reply, {:ok, card_count}, %{state | card_count: card_count}}
    end
  end

  @winning_score 100
  def winner(standings) do
    Enum.find(standings, &(&1.score >= @winning_score))
  end
end
