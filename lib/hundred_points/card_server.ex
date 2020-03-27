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

  def handle_call({:add_card, card}, _from, cards) do
    {:reply, {:ok, card}, [card | cards] |> IO.inspect}
  end
end
