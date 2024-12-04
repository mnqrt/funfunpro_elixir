defmodule Poker.Formatter do
  @moduledoc """
  Module to format a deck of `Poker.Card`
  """
  alias Poker.{Card, Deck}

  @doc """
  Formats a deck of `Poker.Card` by calling its `Poker.Card.to_string/1` function
  """
  @spec format_deck(Card.deck()) :: list(String.t())
  def format_deck(deck \\ Deck.generate()) do
    deck |> Enum.map(&to_string/1)
  end
end
