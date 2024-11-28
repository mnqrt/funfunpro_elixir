defmodule Poker.HandRanking do
  alias Poker.Card

  @suite_rank %{"Spade" => 4, "Heart" => 3, "Diamond" => 2, "Club" => 1}

  @type val_count :: %{count: non_neg_integer(), suite_rank: 1 | 2 | 3 | 4}

  @spec suite_rank() :: %{String.t() => 1 | 2 | 3 | 4}
  def suite_rank, do: @suite_rank

  @spec royal_flush?(boolean(), boolean(), Card.deck()) :: boolean()
  def royal_flush?(is_flush, is_straight, sorted_cards) do
    straight_flush?(is_flush, is_straight) and sorted_cards |> hd() |> Map.get(:value) == 13
  end

  @spec straight_flush?(boolean(), boolean()) :: boolean()
  def straight_flush?(is_flush, is_straight) do
    is_flush and is_straight
  end

  @spec full_house_checker(list(non_neg_integer())) :: boolean()
  defp full_house_checker(counts), do: counts == [2, 3] or counts == [3, 3]

  @spec full_house?(val_count()) :: boolean()
  def full_house?(value_counts) do
    Enum.filter(value_counts, fn {_, %{count: c}} -> c in [2, 3] end)
    |> Enum.map(fn {_, %{count: c}} -> c end)
    |> Enum.sort()
    |> full_house_checker()
  end

  @spec is_flush?(Card.deck()) :: boolean()
  def is_flush?(sorted_cards) do
    sorted_cards
    |> Enum.group_by(&(&1.suite))
    |> Enum.any?(fn {_, grouped_cards} -> length(grouped_cards) >= 5 end)
  end

  @spec is_straight?(Card.deck()) :: boolean()
  def is_straight?(sorted_cards) do
    sorted_cards
    |> Enum.map(&(&1.value))
    |> Enum.uniq()
    |> Enum.sort()
    |> consecutive_count(5)
  end

  @spec consecutive_count(list(non_neg_integer()), non_neg_integer()) :: boolean()
  defp consecutive_count(values, count) do
    case values do
      [a, b | rest] when b == a + 1 -> consecutive_count([b | rest], count - 1)
      [_ | rest] when count > 1 -> consecutive_count(rest, 5)
      _ when count <= 1 -> true
      _ -> false
    end
  end

  @spec count_num(val_count(), non_neg_integer()) :: non_neg_integer()
  defp count_num(value_counts, count) do
    Enum.count(value_counts, fn {_, %{count: ^count}} -> true; _ -> false end)
  end

  @spec four_of_a_kind?(val_count()) :: boolean()
  def four_of_a_kind?(value_counts) do
    count_num(value_counts, 4) == 1
  end

  @spec three_of_a_kind?(val_count()) :: boolean()
  def three_of_a_kind?(value_counts) do
    count_num(value_counts, 3) >= 1
  end

  @spec two_pair?(val_count()) :: boolean()
  def two_pair?(value_counts) do
    count_num(value_counts, 2) >= 2
  end

  @spec one_pair?(val_count()) :: boolean()
  def one_pair?(value_counts) do
    count_num(value_counts, 2) >= 1
  end

  @spec high_card?() :: true
  def high_card? do
    true
  end

  @spec get_value_counts(Card.deck()) :: val_count()
  def get_value_counts(cards) do
    cards
    |> Enum.reduce(%{}, fn (%Card{value: value, suite: suite}, acc) ->
        count = Map.get(acc, value, %{count: 0, suite_rank: 0})
        new_count = %{count | count: count.count + 1, suite_rank: max(count.suite_rank, @suite_rank[suite])}
        Map.put(acc, value, new_count)
      end)
  end

  @spec hand_rank(Card.deck()) :: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10
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
