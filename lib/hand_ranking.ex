defmodule Poker.HandRanking do
  @moduledoc """
  Defines functions to give ranks to a full hand (`Poker.Hand` + `Poker.Board`)
  """

  alias Poker.Card

  @suite_rank %{"Spade" => 4, "Heart" => 3, "Diamond" => 2, "Club" => 1}

  @type val_count :: %{count: non_neg_integer(), suite_rank: 1 | 2 | 3 | 4}

  @doc """
  Returns a mapping of suites to their respective ranks.
  """
  @spec suite_rank() :: %{String.t() => 1 | 2 | 3 | 4}
  def suite_rank, do: @suite_rank

  @doc """
  Compares the value of two `Poker.Card`.
  """
  @spec compare_card_value(Card.t(), Card.t()) :: integer()
  def compare_card_value(%Card{value: value_a, suite: suite_a}, %Card{
        value: value_b,
        suite: suite_b
      }) do
    suite_rank = suite_rank()

    cond do
      value_a != value_b -> value_a - value_b
      true -> suite_rank[suite_a] - suite_rank[suite_b]
    end
  end

  @doc """
  Compares two `Poker.Card`.
  """
  @spec compare_card(Card.t(), Card.t()) :: boolean()
  def compare_card(card1, card2) do
    compare_card_value(card1, card2) > 0
  end

  @doc """
  Sorts a deck of `Poker.Card` with a custom sorter. By default sorts the deck
  descending by their `value` and `suite` for the tie breaker.
  """
  @spec sort_cards(Card.deck(), boolean()) :: Card.deck()
  @spec sort_cards(Card.deck()) :: Card.deck()
  def sort_cards(cards, descending \\ true) do
    sorted = Enum.sort(cards, &compare_card/2)

    if descending do
      sorted
    else
      Enum.reverse(sorted)
    end
  end

  @doc """
  Returns some information about the sorted full hand.
  Information includes the sorted full hand itself, whether the
  full hand is a flush or a straight, the value counts of the
  full hand, and the high card (card with highest ranking suite
  and value).
  """
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

  @doc """
  Deterimines the rank of a full hand using
  slightly modified Poker hands ranking.
  """
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

  @doc """
  Checks if the given full hand has 5 cards with the
  same `suite`.
  """
  @spec is_flush?(Card.deck()) :: boolean()
  def is_flush?(cards) do
    cards
    |> Enum.group_by(& &1.suite)
    |> Enum.any?(fn {_suite, group} -> length(group) >= 5 end)
  end

  @doc """
  Checks if the given full hand has 5 cards that have
  consecutive -1 values.

  ## Example:

      iex> fullhand = [
             %Poker.Card{value: 10, suite: "Spade"},
             %Poker.Card{value: 9, suite: "Spade"},
             %Poker.Card{value: 8, suite: "Heart"},
             %Poker.Card{value: 7, suite: "Spade"},
             %Poker.Card{value: 6, suite: "Diamond"},
             %Poker.Card{value: 1, suite: "Spade"},
             %Poker.Card{value: 1, suite: "Club"}
           ]
      iex> Poker.HandRanking.is_straight?(fullhand)
      true

  """
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

  @doc """
  Checks if the given full hand is a straight flush
  with the highest value card being the King with value 13.
  """
  @spec royal_flush?(boolean(), boolean(), Card.deck()) :: boolean()
  def royal_flush?(is_flush, is_straight, sorted_cards),
    do: straight_flush?(is_flush, is_straight) and hd(sorted_cards).value == 13

  @doc """
  Checks if the given full hand is both a flush
  and a straight
  """
  @spec straight_flush?(boolean(), boolean()) :: boolean()
  def straight_flush?(is_flush, is_straight), do: is_flush and is_straight

  @doc """
  Checks if the given full hand has four cards
  with the same value.
  """
  @spec four_of_a_kind?(list(map())) :: boolean()
  def four_of_a_kind?(value_counts),
    do: Enum.any?(value_counts, &(&1.count == 4))

  @doc """
  Checks if the given full hand has a one pair and
  three of a kind with no overlapping cards.
  """
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

  @doc """
  Checks if the given full hand has three cards with
  the same value.
  """
  @spec three_of_a_kind?(list(map())) :: boolean()
  def three_of_a_kind?(value_counts),
    do: Enum.any?(value_counts, &(&1.count == 3))

  @doc """
  Checks if the given full hand has two pairs of cards with
  the same value.
  """
  @spec two_pair?(list(map())) :: boolean()
  def two_pair?(value_counts),
    do: Enum.count(value_counts, &(&1.count == 2)) >= 2

  @doc """
  Checks if the given full hand has one pair of cards with
  the same value.
  """
  @spec one_pair?(list(map())) :: boolean()
  def one_pair?(value_counts),
    do: Enum.any?(value_counts, &(&1.count == 2))

  @doc """
  Checks if the given full hand is a high card.
  """
  @spec high_card?() :: true
  def high_card?(), do: true

  @doc """
  Gets the values of all `Poker.Card` in the full hand
  """
  @spec get_value_counts(Card.deck()) :: list(%{value: integer(), count: integer()})
  def get_value_counts(cards) do
    cards
    |> Enum.group_by(& &1.value)
    |> Enum.map(fn {value, group} -> %{value: value, count: length(group)} end)
    |> Enum.sort_by(& &1.count, :desc)
  end
end
