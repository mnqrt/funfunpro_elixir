defmodule Poker.Formatter do
  alias Poker.{Card, Deck}

  @spec format_deck(Card.deck()) :: list(String.t())
  def format_deck(deck \\ Deck.generate()) do
    deck |> Enum.map(&to_string/1)
  end
end
