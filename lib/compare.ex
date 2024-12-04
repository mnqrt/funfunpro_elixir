defmodule Poker.Rank do
  @moduledoc """
  Defines functions to rank `Poker.Hand`s
  """

  alias Poker.{Board, Card, Hand, HandRanking}

  @doc """
  Ranks a given full hand (`Poker.Hand` + `Poker.Board`)
  """
  @spec rank_hand(Card.deck()) :: %{
          rank: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10,
          high_card: Card.t()
        }
  def rank_hand(cards) do
    cards
    |> HandRanking.sort_cards()
    |> HandRanking.process_sorted_cards()
    |> HandRanking.determine_rank()
  end

  @doc """
  Compares 2 `Poker.Hand` and returns the winner.
  """
  @spec compare_hands(Board.t(), Hand.t(), Hand.t()) :: String.t()
  def compare_hands(board, %Hand{card1: card1a, card2: card2a}, %Hand{
        card1: card1b,
        card2: card2b
      }) do
    full_hand1 = [card1a, card2a, board.card1, board.card2, board.card3, board.card4, board.card5]
    full_hand2 = [card1b, card2b, board.card1, board.card2, board.card3, board.card4, board.card5]

    task1 = Task.async(fn -> rank_hand(full_hand1) end)
    task2 = Task.async(fn -> rank_hand(full_hand2) end)

    rank1 = Task.await(task1)
    rank2 = Task.await(task2)
    comparison = HandRanking.compare_card_value(rank1.high_card, rank2.high_card)

    cond do
      rank1.rank > rank2.rank -> "Hand1"
      rank2.rank > rank1.rank -> "Hand2"
      comparison > 0 -> "Hand1"
      comparison < 0 -> "Hand2"
      true -> "Tie"
    end
  end
end

alias Poker.{Card, Hand, Board, Rank}

hand1 = %Hand{
  card1: %Card{value: 10, suite: "Heart"},
  card2: %Card{value: 11, suite: "Heart"}
}

hand2 = %Hand{
  card1: %Card{value: 10, suite: "Spade"},
  card2: %Card{value: 11, suite: "Spade"}
}

board = %Board{
  card1: %Card{value: 9, suite: "Heart"},
  card2: %Card{value: 12, suite: "Heart"},
  card3: %Card{value: 13, suite: "Heart"},
  card4: %Card{value: 2, suite: "Spade"},
  card5: %Card{value: 5, suite: "Club"}
}

IO.inspect(Rank.compare_hands(board, hand1, hand2))
