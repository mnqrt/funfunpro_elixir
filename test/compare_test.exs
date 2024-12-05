defmodule Poker.RankTest do
  use ExUnit.Case
  doctest Poker.Rank

  test "hit only grabs the first card" do
    player = [Poker.Card.create(4, "Heart"), Poker.Card.create(2, "Spade")]
    deck = [Poker.Card.create(9, "Heart"), Poker.Card.create(9, "Spade"), Poker.Card.create(5, "Diamond")]
    {result, rest} = Poker.Rank.hit(player, deck)
    assert length(player) == length(result) - 1
    assert length(deck) == length(rest) + 1
    assert hd(result) == Poker.Card.create(9, "Heart")
  end

  test "hit until stops after the hand has total value at least stop_val" do
    stop_val = 13
    player = [Poker.Card.create(4, "Heart"), Poker.Card.create(2, "Spade")]
    deck = [Poker.Card.create(9, "Heart"), Poker.Card.create(9, "Spade"), Poker.Card.create(5, "Diamond")]
    {result, _} = Poker.Rank.hit_until(stop_val).(player, deck)
    player_val = result |> Enum.map(&(&1.value)) |> Enum.sum()
    assert player_val >= stop_val
  end

  test "hit_until only accepts stop value within [1..21]" do
    assert catch_error(Poker.Rank.hit_until(0)) == :function_clause
    assert catch_error(Poker.Rank.hit_until(22)) == :function_clause
  end

  test "blackjack player wins" do
    player = [Poker.Card.create(4, "Heart"), Poker.Card.create(9, "Spade"), Poker.Card.create(5, "Diamond")]
    dealer = [Poker.Card.create(11, "Club"), Poker.Card.create(6, "Spade")]
    assert Poker.Rank.compare_blackjack(player, dealer) == "Player Wins"
  end
end
