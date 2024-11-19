defmodule Poker.Validator do
  alias Poker.Card

  def validate_card(%Card{}), do: :ok

  def validate_card(invalid) do
    raise ArgumentError, "Invalid card: #{inspect(invalid)}. Expected a %Poker.Card{} struct."
  end
end
