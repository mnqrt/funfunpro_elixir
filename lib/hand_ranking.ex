defmodule Poker.HandRanking do
  alias Poker.Card

  @suite_rank %{"Spade" => 4, "Heart" => 3, "Diamond" => 2, "Club" => 1}

  def royal_flush?(is_flush, is_straight, sorted_cards) do
    is_flush and is_straight and sorted_cards |> hd() |> Map.get(:value) == 13
  end

  def straight_flush?(is_flush, is_straight) do
    is_flush and is_straight
  end

  def four_of_a_kind?(value_counts) do
    Enum.any?(value_counts, fn {_, %{count: 4}} -> true; _ -> false end)
  end

  def full_house?(value_counts) do
    Enum.filter(value_counts, fn {_, %{count: c}} -> c in [2, 3] end)
    |> Enum.map(fn {_, %{count: c}} -> c end)
    |> Enum.sort()
    |> (&(&1 == [2, 3] or &1 == [3, 3])).()
  end

  def is_flush?(cards) do
    cards
    |> Enum.group_by(& &1.suite)
    |> Enum.any?(fn {_suite, grouped_cards} -> length(grouped_cards) >= 5 end)
  end

  def is_straight?(cards) do
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

  def three_of_a_kind?(value_counts) do
    Enum.any?(value_counts, fn {_, %{count: 3}} -> true; _ -> false end)
  end

  def two_pair?(value_counts) do
    Enum.count(value_counts, fn {_, %{count: 2}} -> true; _ -> false end) == 2
  end

  def one_pair?(value_counts) do
    Enum.any?(value_counts, fn {_, %{count: 2}} -> true; _ -> false end)
  end

  def high_card? do
    true
  end

  def get_value_counts(cards) do
    cards
    |> Enum.reduce(%{}, fn (%Card{value: value, suite: suite}, acc) ->
      count = Map.get(acc, value, %{count: 0, suite_rank: 0})
      new_count = %{count | count: count.count + 1, suite_rank: max(count.suite_rank, @suite_rank[suite])}
      Map.put(acc, value, new_count)
    end)
  end

  def hand_rank(sorted_cards) do
    is_flush = is_flush?(sorted_cards)
    is_straight = is_straight?(sorted_cards)
    value_counts = get_value_counts(sorted_cards)

    cond do
      royal_flush?(is_flush, is_straight, sorted_cards) -> 10
      straight_flush?(is_flush, is_straight) -> 9
      four_of_a_kind?(value_counts) -> 8
      full_house?(value_counts) -> 7
      is_flush -> 6
      is_straight -> 5
      three_of_a_kind?(value_counts) -> 4
      two_pair?(value_counts) -> 3
      one_pair?(value_counts) -> 2
      high_card?() -> 1
    end
  end
end
