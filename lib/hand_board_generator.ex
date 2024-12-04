defmodule Poker.HandBoardGenerator do
  @moduledoc """
  Defines functions to generate `Poker.Hand` and `Poker.Board`.
  """

  alias Poker.Card
  alias Poker.Hand
  alias Poker.Board

  @doc """
  Generates `player_count` `Poker.Hand`s from the deck.

  ## Example

      iex> deck = Poker.Shuffle.shuffle_deck()
      iex> Poker.HandBoardGenerator.generate_hands(2).(deck)
      {[
        [
          %Poker.Card{value: 2, suite: "Spade"},
          %Poker.Card{value: 8, suite: "Diamond"}
        ],
        [
          %Poker.Card{value: 7, suite: "Diamond"},
          %Poker.Card{value: 1, suite: "Club"}
        ]
      ],
      [
        %Poker.Card{value: 7, suite: "Spade"},
        %Poker.Card{value: 8, suite: "Spade"},
        %Poker.Card{...}
      ]}

  """
  @spec generate_hands(non_neg_integer()) :: ((Card.deck() -> {list(Hand.t()), Card.deck()}))
  def generate_hands(player_count) do
    fn deck ->
      {
        Enum.chunk_every(deck, 2)
        |> Enum.take(player_count) |> Enum.map(&Hand.create_from_list/1), Enum.drop(deck, player_count * 2)
      }
    end
  end

  @doc """
  Generates the `Poker.Board` from a given `deck`.

  ## Example

      iex> deck = Poker.Shuffle.shuffle_deck()
      iex> Poker.HandBoardGenerator.generate_board().(deck)
      {%Poker.Board{
        card1: %Poker.Card{value: 2, suite: "Spade"},
        card2: %Poker.Card{value: 8, suite: "Diamond"},
        card3: %Poker.Card{value: 7, suite: "Diamond"},
        card4: %Poker.Card{value: 1, suite: "Club"},
        card5: %Poker.Card{value: 7, suite: "Spade"}
      },
      [
        %Poker.Card{value: 8, suite: "Spade"},
        %Poker.Card{value: 5, suite: "Diamond"},
        %Poker.Card{...}
      ]

  """
  @spec generate_board() :: (Card.deck() -> {Board.t(), Card.deck()})
  def generate_board do
    fn [card1, card2, card3, card4, card5 | rest] ->
      {Board.create(card1, card2, card3, card4, card5), rest}
    end
  end
end
