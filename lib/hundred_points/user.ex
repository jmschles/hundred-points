defmodule HundredPoints.User do
  @derive Jason.Encoder
  defstruct username: nil, moderator: false, score: 0
end
