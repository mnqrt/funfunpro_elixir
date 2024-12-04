defmodule Poker.Deck do
  @moduledoc """
  Defines the function to generate the initial deck of `Poker.Card`.
  """
  alias Poker.Card

  @doc """
  Generates a deck of (unshuffled) `Poker.Card`
  """
  @spec generate() :: Card.deck()
  def generate do
    Card.suites()
    |> Enum.flat_map(fn suites ->
      Card.values() |> Enum.map(&Card.create(&1, suites))
    end)
  end
end
