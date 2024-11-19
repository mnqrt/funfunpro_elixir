defmodule Poker.Deck do
  alias Poker.Card

  def generate do
    Card.values()
    |> Enum.flat_map(fn value ->
      Card.suites() |> Enum.map(&Card.create(value, &1))
    end)
  end
end
