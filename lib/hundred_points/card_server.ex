defmodule HundredPoints.CardServer do
  use GenServer
  alias HundredPoints.Card

  def init(cards) do
    {:ok, cards}
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

  def clear_cards do
    GenServer.cast(__MODULE__, :clear_cards)
  end

  def handle_call({:add_card, card}, _from, cards) do
    updated_card_list = cards ++ [card]
    {:reply, {:ok, length(updated_card_list)}, updated_card_list}
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

  def handle_cast(:clear_cards, _cards) do
    {:noreply, []}
  end
end
