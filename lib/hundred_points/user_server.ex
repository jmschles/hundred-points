defmodule HundredPoints.UserServer do
  use GenServer
  alias HundredPoints.User

  def init(players) do
    {:ok, players}
  end

  def start_link(players) do
    GenServer.start_link(__MODULE__, players, name: __MODULE__)
  end

  def add_player(username) do
    GenServer.call(__MODULE__, {:add_player, username})
  end

  # TODO: this is for scoring, maybe game responsibility
  def standings do
    GenServer.call(__MODULE__, :standings)
  end

  def players_in_turn_order do
    GenServer.call(__MODULE__, :players)
  end

  def reset_scores do
    GenServer.call(__MODULE__, :reset_scores)
  end

  def get_active_player do
    GenServer.call(__MODULE__, :get_active_player)
  end

  def next_active_player do
    GenServer.call(__MODULE__, :next_active_player)
  end

  def select_active_player(username) do
    GenServer.call(__MODULE__, {:select_active_player, username})
  end

  def award_points(points) do
    GenServer.call(__MODULE__, {:award_points, points})
  end

  def shuffle_players do
    GenServer.cast(__MODULE__, :shuffle_players)
  end

  def reassign_moderator(username) do
    GenServer.cast(__MODULE__, {:reassign_moderator, username})
  end

  def kick_player(username) do
    GenServer.cast(__MODULE__, {:kick_player, username})
  end

  def handle_call({:add_player, username}, _from, players) do
    case validate_username(players, username) do
      :ok ->
        moderator = Enum.empty?(players)
        user = %User{username: username, moderator: moderator}
        {:reply, {:ok, user}, [user | players]}

      {:error, error} ->
        {:reply, {:error, error}, players}
    end
  end

  def handle_call(:standings, _from, players) do
    {:reply, Enum.sort(players, &(&1.score >= &2.score)), players}
  end

  def handle_call(:players, _from, players) do
    {:reply, players, players}
  end

  def handle_call(:reset_scores, _from, players) do
    reset_players = Enum.map(players, &%{&1 | score: 0})
    {:reply, reset_players, reset_players}
  end

  def handle_call(:get_active_player, _from, [active_player | _other_players] = players) do
    {:reply, active_player, players}
  end

  # If you're playing by yourself, or testing, or just trying to break stuff
  def handle_call(:next_active_player, _from, [lonely_player]) do
    {:reply, lonely_player, [lonely_player]}
  end

  def handle_call(:next_active_player, _from, [active_player | [next_player | other_players]]) do
    {:reply, next_player, [next_player | other_players ++ [active_player]]}
  end

  def handle_call({:select_active_player, username}, _from, players) do
    [next_player | other_players] = rotate_to_user(username, players)
    {:reply, next_player, [next_player | other_players]}
  end

  def handle_call({:award_points, points}, _from, [active_player | [next_player | other_players]]) do
    {
      :reply,
      next_player,
      [next_player |
        other_players ++ [
          %{active_player | score: active_player.score + points}
        ]
      ]
    }
  end

  def handle_cast(:shuffle_players, players) do
    {:noreply, Enum.shuffle(players)}
  end

  def handle_cast({:reassign_moderator, username}, players) do
    {:noreply, Enum.map(players, &%{&1 | moderator: &1.username == username})}
  end

  def handle_cast({:kick_player, username}, players) do
    {:noreply, Enum.reject(players, & &1.username == username)}
  end

  defp find_user(players, username) do
    Enum.find(players, & &1.username == username)
  end

  defp rotate_to_user(username, [%{username: username} | _other_players] = players) do
    players
  end

  defp rotate_to_user(username, [next_up | other_players]) do
    rotate_to_user(username, other_players ++ [next_up])
  end

  @min_length 3
  @max_length 24
  defp validate_username(players, username) do
    case String.length(username) do
      n when n < @min_length ->
        {:error, "Username must be at least 3 characters"}

      n when n > @max_length ->
        {:error, "Username may not exceed 24 characters"}

      _ ->
        case find_user(players, username) do
          %User{} -> {:error, "Username taken!"}
          nil -> :ok
        end
    end
  end
end
