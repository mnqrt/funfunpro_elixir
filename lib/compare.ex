defmodule Poker.Rank do
  alias Poker.{Board, Card, Hand, HandRanking}

  @spec compare_card_value(Card.t(), Card.t()) :: integer()
  def compare_card_value(%Card{value: value_a, suite: suite_a}, %Card{value: value_b, suite: suite_b}) do
    suite_rank = HandRanking.suite_rank()

    case {value_a, value_b} do
      {a, b} when a != b -> a - b
      _ -> suite_rank[suite_a] - suite_rank[suite_b]
    end
  end

  @spec compare_card(Card.t(), Card.t()) :: boolean()
  def compare_card(card1, card2) do
    compare_card_value(card1, card2) > 0
  end

  @spec sort_cards(Card.deck(), boolean()) :: Card.deck()
  def sort_cards(cards, ascending \\ true) do
    sorted = Enum.sort(cards, &compare_card/2)
    unless ascending do
      Enum.reverse(sorted)
    else
      sorted
    end
  end

  @spec rank_hand(Card.deck()) :: map()
  def rank_hand(cards) do
    sorted_cards = sort_cards(cards)

    rank = sorted_cards |> HandRanking.hand_rank()
    %{rank: rank, high_card: hd(sorted_cards)}
  end

  @spec compare_hands(Board.t(), Hand.t(), Hand.t()) :: String.t()
  def compare_hands(board, %Hand{card1: card1a, card2: card2a}, %Hand{card1: card1b, card2: card2b}) do
    full_hand1 = [card1a, card2a, board.card1, board.card2, board.card3, board.card4, board.card5]
    full_hand2 = [card1b, card2b, board.card1, board.card2, board.card3, board.card4, board.card5]

    task1 = Task.async(fn -> rank_hand(full_hand1) end)
    task2 = Task.async(fn -> rank_hand(full_hand2) end)

    rank1 = Task.await(task1)
    rank2 = Task.await(task2)
    comparison = compare_card_value(rank1.high_card, rank2.high_card)

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
