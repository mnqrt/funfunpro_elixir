defmodule Poker.Formatter do
  alias Poker.{Card, Deck}

  @spec format_card(Card.t()) :: String.t()
  def format_card(card) do
    card.suite <> " " <> Integer.to_string(card.value)
  end

  def print_deck() do
    Deck.generate() |> Enum.map(&format_card/1)
  end
end
