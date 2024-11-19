defmodule Poker.Deck do
  alias Poker.Card

  def generate do
    Card.suites()
    |> Enum.flat_map(
      fn suites ->
        Card.values() |> Enum.map(&Card.create(&1, suites))
      end
    )
  end
end
