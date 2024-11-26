defmodule Poker.Rank do
  alias Poker.{Card, Hand}

  @suite_rank %{"Spade" => 4, "Heart" => 3, "Diamond" => 2, "Club" => 1}

  def compare_card_value(%Card{value: value_a, suite: suite_a}, %Card{value: value_b, suite: suite_b}) do
    case {value_a, value_b} do
      {a, b} when a != b -> b - a
      _ -> @suite_rank[suite_b] - @suite_rank[suite_a]
    end
  end

  def compare_card(card1, card2) do
    compare_card_value(card1, card2) > 0
  end

  def sort_cards(cards) do
    Enum.sort(cards, &compare_card/2)
  end

  def is_flush(cards) do
    cards
    |> Enum.group_by(& &1.suite)
    |> Enum.any?(fn {_suite, grouped_cards} -> length(grouped_cards) >= 5 end)
  end

  def is_straight(cards) do
    cards |> Enum.map(& &1.value) |> Enum.uniq() |> Enum.sort() |> consecutive_count(5)
  end

  defp consecutive_count(values, count) do
    case values do
      [a, b | rest] when b == a + 1 -> consecutive_count([b | rest], count - 1)
      [_ | rest] when count > 1 -> consecutive_count(rest, 5)
      _ when count <= 1 -> true
      _ -> false
    end
  end

  def get_value_counts(cards) do
    cards
    |> Enum.reduce(%{}, fn %Card{value: value, suite: suite}, acc ->
      count = Map.get(acc, value, %{count: 0, suite_rank: 0})
      new_count = %{count | count: count.count + 1, suite_rank: max(count.suite_rank, @suite_rank[suite])}
      Map.put(acc, value, new_count)
    end)
  end

  def rank_hand(cards) do
    sorted_cards = sort_cards(cards)
    value_counts = get_value_counts(sorted_cards)

    is_flush = is_flush(sorted_cards)
    is_straight = is_straight(sorted_cards)

    rank =
      cond do
        is_flush and is_straight and sorted_cards |> hd() |> Map.get(:value) == 13 -> 10
        is_flush and is_straight -> 9
        Enum.any?(value_counts, fn {_, %{count: 4}} -> true; _ -> false end) -> 8
        Enum.any?(value_counts, fn {_, %{count: 3}} -> true; _ -> false end) and Enum.any?(value_counts, fn {_, %{count: 2}} -> true; _ -> false end) -> 7
        is_flush -> 6
        is_straight -> 5
        Enum.any?(value_counts, fn {_, %{count: 3}} -> true; _ -> false end) -> 4
        Enum.count(value_counts, fn {_, %{count: 2}} -> true; _ -> false end) == 2 -> 3
        Enum.any?(value_counts, fn {_, %{count: 2}} -> true; _ -> false end) -> 2
        true -> 1
      end

    %{rank: rank, high_card: hd(sorted_cards)}
  end

  def compare_hands(board, %Hand{card1: card1a, card2: card2a}, %Hand{card1: card1b, card2: card2b}) do
    full_hand1 = [card1a, card2a, board.card1, board.card2, board.card3, board.card4, board.card5]
    full_hand2 = [card1b, card2b, board.card1, board.card2, board.card3, board.card4, board.card5]

    rank1 = rank_hand(full_hand1)
    rank2 = rank_hand(full_hand2)

    cond do
      rank1.rank > rank2.rank -> "Hand1"
      rank2.rank > rank1.rank -> "Hand2"
      compare_card(rank1.high_card, rank2.high_card) > 0 -> "Hand1"
      compare_card(rank1.high_card, rank2.high_card) < 0 -> "Hand2"
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
