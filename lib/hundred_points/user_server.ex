defmodule HundredPoints.UserServer do
  use GenServer
  alias HundredPoints.User

  def init(users) do
    {:ok, users}
  end

  def start_link(users) do
    GenServer.start_link(__MODULE__, users, name: __MODULE__)
  end

  def add_user(username) do
    GenServer.call(__MODULE__, {:add_user, username})
  end

  def handle_call({:add_user, username}, _from, users) do
    case validate_username(users, username) do
      :ok ->
        moderator = Enum.empty?(users)
        user = %User{username: username, moderator: moderator}
        {:reply, {:ok, user}, [user | users]}

      {:error, error} ->
        {:reply, {:error, error}, users}
    end
  end

  def find_user(users, username) do
    Enum.find(users, & &1.username == username)
  end

  @min_length 3
  @max_length 24
  defp validate_username(users, username) do
    case String.length(username) do
      n when n < @min_length ->
        {:error, "Username must be at least 3 characters"}

      n when n > @max_length ->
        {:error, "Username may not exceed 24 characters"}

      _ ->
        case find_user(users, username) do
          %User{} -> {:error, "Username taken!"}
          nil -> :ok
        end
    end
  end
end
