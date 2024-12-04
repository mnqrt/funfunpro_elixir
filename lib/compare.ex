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

  @doc """
  Grabs the first value from `deck` and add it to the current hand
  """
  @spec hit(list(Card.t()), Card.deck()) :: {list(Card.t()), Card.deck()}
  def hit(hand, [first | deck]), do: {[first | hand], deck}

  @doc """
  Hits until the total value of hand is at least `stop_val`.
  `stop_val` can only be in the range [1..21]
  """
  @spec hit_until(non_neg_integer()) :: ((list(Card.t()), Card.deck()) -> {list(Card.t()), Card.deck()})
  def hit_until(stop_val) when stop_val > 0 and stop_val < 22 do
    fn hand, deck ->
      {result, rest} = hit(hand, deck)
      value = Enum.map(result, &(&1.value)) |> Enum.sum()
      if value < stop_val do
        hit_until(stop_val).(result, rest)
      else
        {result, rest}
      end
    end
  end

  @doc """
  When the player stands, the dealer gets to hit until the total
  value of their hand is at least 17.
  """
  @spec stand(list(Card.t()), Card.deck()) :: {list(Card.t()), Card.deck()}
  def stand(dealer, deck), do: hit_until(17).(dealer, deck)

  @doc """
  Compares the player's hand with the dealer's hand and determines
  the winner.
  """
  @spec compare_blackjack(list(Card.t()), list(Card.t())) :: String.t()
  def compare_blackjack(player, dealer) do
    player_val = get_sum(player)
    dealer_val = get_sum(dealer)

    cond do
      player_val > 21 -> "Dealer Wins"
      dealer_val > 21 -> "Player Wins"
      player_val > dealer_val -> "Player Wins"
      dealer_val > player_val -> "Dealer Wins"
      true -> "Tie"
    end
  end

  defp get_sum(hand), do: hand |> Enum.map(&(&1.value)) |> Enum.sum()
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
