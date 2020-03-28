defmodule HundredPoints.Game do
  @derive Jason.Encoder
  defstruct [:phase, :active_player, :active_card, :winner, :standings, :players]
end
