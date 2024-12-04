defmodule Poker.HandRanking do
  alias Poker.Card

  @suite_rank %{"Spade" => 4, "Heart" => 3, "Diamond" => 2, "Club" => 1}

  @type val_count :: %{count: non_neg_integer(), suite_rank: 1 | 2 | 3 | 4}

  @spec suite_rank() :: %{String.t() => 1 | 2 | 3 | 4}
  def suite_rank, do: @suite_rank

  @spec hand_rank(Card.deck()) :: %{rank: integer(), high_card: Card.t()}
  def hand_rank(cards) do
    cards
    |> sort_cards()
    |> process_sorted_cards()
    |> determine_rank()
  end

  @spec compare_card_value(Card.t(), Card.t()) :: integer()
  def compare_card_value(%Card{value: value_a, suite: suite_a}, %Card{value: value_b, suite: suite_b}) do
    suite_rank = suite_rank()

    cond do
      value_a != value_b -> value_a - value_b
      true -> suite_rank[suite_a] - suite_rank[suite_b]
    end
  end

  @spec compare_card(Card.t(), Card.t()) :: boolean()
  def compare_card(card1, card2) do
    compare_card_value(card1, card2) > 0
  end

  @spec sort_cards(Card.deck(), boolean()) :: Card.deck()
  def sort_cards(cards, ascending \\ true) do
    sorted = Enum.sort(cards, &compare_card/2)

    if ascending do
      sorted
    else
      Enum.reverse(sorted)
    end
  end

  @spec process_sorted_cards(Card.deck()) :: %{
          sorted_cards: Card.deck(),
          is_flush: boolean(),
          is_straight: boolean(),
          value_counts: list(%{value: integer(), count: integer()}),
          high_card: Card.t()
        }
  def process_sorted_cards(sorted_cards) do
    %{
      sorted_cards: sorted_cards,
      is_flush: is_flush?(sorted_cards),
      is_straight: is_straight?(sorted_cards),
      value_counts: get_value_counts(sorted_cards),
      high_card: hd(sorted_cards)
    }
  end

  @spec determine_rank(map()) :: %{rank: integer(), high_card: Card.t()}
  def determine_rank(%{
        is_flush: is_flush,
        is_straight: is_straight,
        value_counts: value_counts,
        high_card: high_card,
        sorted_cards: sorted_cards
      }) do
    rank_conditions = [
      {10, fn -> royal_flush?(is_flush, is_straight, sorted_cards) end},
      {9, fn -> straight_flush?(is_flush, is_straight) end},
      {8, fn -> four_of_a_kind?(value_counts) end},
      {7, fn -> full_house?(value_counts) end},
      {6, fn -> is_flush end},
      {5, fn -> is_straight end},
      {4, fn -> three_of_a_kind?(value_counts) end},
      {3, fn -> two_pair?(value_counts) end},
      {2, fn -> one_pair?(value_counts) end},
      {1, fn -> high_card?() end}
    ]

    rank = Enum.find_value(rank_conditions, fn {rank, condition} -> if condition.(), do: rank end)
    %{rank: rank, high_card: high_card}
  end

  @spec is_flush?(Card.deck()) :: boolean()
  def is_flush?(cards) do
    cards
    |> Enum.group_by(& &1.suite)
    |> Enum.any?(fn {_suite, group} -> length(group) >= 5 end)
  end

  @spec is_straight?(Card.deck()) :: boolean()
  def is_straight?(cards) do
    cards
    |> Enum.map(& &1.value)
    |> Enum.uniq()
    |> Enum.sort()
    |> consecutive_count(5)
  end

  @spec consecutive_count(list(integer()), integer()) :: boolean()
  defp consecutive_count(values, count) do
    case values do
      [a, b | rest] when b == a + 1 -> consecutive_count([b | rest], count - 1)
      [_ | rest] when count > 1 -> consecutive_count(rest, 5)
      _ when count <= 1 -> true
      _ -> false
    end
  end

  @spec royal_flush?(boolean(), boolean(), Card.deck()) :: boolean()
  def royal_flush?(is_flush, is_straight, sorted_cards),
    do: straight_flush?(is_flush, is_straight) and hd(sorted_cards).value == 13

  @spec straight_flush?(boolean(), boolean()) :: boolean()
  def straight_flush?(is_flush, is_straight), do: is_flush and is_straight

  @spec four_of_a_kind?(list(map())) :: boolean()
  def four_of_a_kind?(value_counts),
    do: Enum.any?(value_counts, &(&1.count == 4))

  @spec full_house?(list(map())) :: boolean()
  def full_house?(value_counts) do
    value_counts
    |> Enum.map(& &1.count)
    |> Enum.sort()
    |> case do
      [2, 3] -> true
      [3, 3] -> true
      _ -> false
    end
  end

  @spec three_of_a_kind?(list(map())) :: boolean()
  def three_of_a_kind?(value_counts),
    do: Enum.any?(value_counts, &(&1.count == 3))

  @spec two_pair?(list(map())) :: boolean()
  def two_pair?(value_counts),
    do: Enum.count(value_counts, &(&1.count == 2)) >= 2

  @spec one_pair?(list(map())) :: boolean()
  def one_pair?(value_counts),
    do: Enum.any?(value_counts, &(&1.count == 2))

  @spec high_card?() :: true
  def high_card?(), do: true

  @spec get_value_counts(Card.deck()) :: list(%{value: integer(), count: integer()})
  def get_value_counts(cards) do
    cards
    |> Enum.group_by(& &1.value)
    |> Enum.map(fn {value, group} -> %{value: value, count: length(group)} end)
    |> Enum.sort_by(& &1.count, :desc)
  end
end
