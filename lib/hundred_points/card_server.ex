defmodule HundredPoints.CardServer do
  use GenServer
  alias HundredPoints.Card

  def init(cards) do
    # REMOVE ME
    {:ok, seed_cards()}
  end

  def start_link(cards) do
    GenServer.start_link(__MODULE__, cards, name: __MODULE__)
  end

  def add_card(params) do
    case Card.build(params) do
      {:error, error} -> {:error, error}
      %Card{} = card -> GenServer.call(__MODULE__, {:add_card, card})
    end
  end

  def next_card do
    GenServer.call(__MODULE__, :next_card)
  end

  def shuffle_cards do
    GenServer.cast(__MODULE__, :shuffle_cards)
  end

  def handle_call({:add_card, card}, _from, cards) do
    {:reply, {:ok, card}, cards ++ [card]}
  end

  def handle_call(:next_card, _from, []) do
    {:reply, nil, []}
  end

  def handle_call(:next_card, _from, [next_card | rest_of_cards]) do
    {:reply, next_card, rest_of_cards}
  end

  def handle_cast(:shuffle_cards, cards) do
    {:noreply, Enum.shuffle(cards)}
  end

  defp seed_cards do
    [
      %Card{points: 10, action: "Jump"},
      %Card{points: 20, action: "Hide"},
      %Card{points: 30, action: "Giggle"},
      %Card{points: 50, action: "Dance"}
    ]
  end
end
