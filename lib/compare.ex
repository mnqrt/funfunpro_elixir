defmodule Poker.Rank do
  alias Poker.{Card, Hand, HandRanking}

  @suite_rank %{"Spade" => 4, "Heart" => 3, "Diamond" => 2, "Club" => 1}

  def compare_card_value(%Card{value: value_a, suite: suite_a}, %Card{value: value_b, suite: suite_b}) do
    case {value_a, value_b} do
      {a, b} when a != b -> a - b
      _ -> @suite_rank[suite_b] - @suite_rank[suite_a]
    end
  end

  def compare_card(card1, card2) do
    compare_card_value(card1, card2) > 0
  end

  def sort_cards(cards) do
    Enum.sort(cards, &compare_card/2)
  end

  def rank_hand(cards) do
    sorted_cards = sort_cards(cards)

    rank = sorted_cards |> HandRanking.hand_rank()
    %{rank: rank, high_card: hd(sorted_cards)}
  end

  def compare_hands(board, %Hand{card1: card1a, card2: card2a}, %Hand{card1: card1b, card2: card2b}) do
    full_hand1 = [card1a, card2a, board.card1, board.card2, board.card3, board.card4, board.card5]
    full_hand2 = [card1b, card2b, board.card1, board.card2, board.card3, board.card4, board.card5]

    rank1 = rank_hand(full_hand1)
    rank2 = rank_hand(full_hand2)
    comparison = compare_card(rank1.high_card, rank2.high_card)

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
