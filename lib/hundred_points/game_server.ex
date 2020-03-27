defmodule HundredPoints.GameServer do
  use GenServer
  alias HundredPoints.Game

  def init(_initial_state) do
    {:ok, %Game{phase: :preparation, standings: []}}
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

  def get_game_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def pass_turn do
    GenServer.call(__MODULE__, :pass_turn)
  end

  def pass_to_player(username) do
    GenServer.call(__MODULE__, {:pass_to_player, username})
  end

  def action_performed do
    GenServer.call(__MODULE__, :action_performed)
  end

  def handle_call(:restart_game, _from, state) do
    HundredPoints.UserServer.reset_scores()

    updated_state = %{
      state |
        active_card: nil,
        active_player: nil,
        winner: nil,
        standings: HundredPoints.UserServer.standings(),
        phase: :preparation,
    }

    {:reply, updated_state, updated_state}
  end

  def handle_call(:begin_play, _from, state) do
    HundredPoints.UserServer.shuffle_players()
    HundredPoints.CardServer.shuffle_cards()

    updated_state = %{state |
      phase: :playing,
      active_player: HundredPoints.UserServer.next_active_player(),
      active_card: HundredPoints.CardServer.next_card(),
      standings: HundredPoints.UserServer.standings()
    }

    {:reply, updated_state, updated_state}
  end

  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  def handle_call(:pass_turn, _from, state) do
    updated_state = %{
      state | active_player: HundredPoints.UserServer.next_active_player()
    }
    {:reply, updated_state, updated_state}
  end

  def handle_call({:pass_to_player, username}, _from, state) do
    updated_state = %{
      state | active_player: HundredPoints.UserServer.select_active_player(username)
    }
    {:reply, updated_state, updated_state}
  end

  def handle_call(:action_performed, _from, %{active_card: %{points: points}} = state) do
    next_active_player = HundredPoints.UserServer.award_points(points)
    updated_standings = HundredPoints.UserServer.standings()

    updated_state = case winner(updated_standings) do
      nil ->
        %{
          state |
            active_card: HundredPoints.CardServer.next_card(),
            active_player: next_active_player,
            standings: updated_standings
        }

      %HundredPoints.User{} = winner ->
        %{
          state |
            active_card: nil,
            active_player: nil,
            standings: updated_standings,
            state: :game_over,
            winner: winner
        }
      end

    {:reply, updated_state, updated_state}
  end

  @winning_score 100
  def winner(standings) do
    Enum.find(standings, & &1.score >= @winning_score)
  end
end
