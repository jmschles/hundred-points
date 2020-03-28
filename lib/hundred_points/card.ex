defmodule HundredPoints.Card do
  defstruct [:action, :points]

  def build(%{"action" => action, "points" => points}) do
    validate_points(points)
    |> validate_action(action)
    |> case do
      :ok -> %__MODULE__{action: action, points: String.to_integer(points)}
      {:error, error} -> {:error, error}
    end
  end

  def validate_points(points) do
    try do
      case String.to_integer(points) do
        n when n < 1 or n > 100 -> {:error, "Points must be positive integers between 1 and 100"}
        _ -> :ok
      end
    rescue
      _ -> {:error, "Points must be integers"}
    end
  end

  def validate_action({:error, error}, _action), do: {:error, error}

  def validate_action(:ok, action) do
    case String.length(action) do
      n when n < 4 -> {:error, "Actions must be at least 4 characters."}
      n when n > 255 -> {:error, "Actions may not exceed 255 characters."}
      _ -> :ok
    end
  end
end
