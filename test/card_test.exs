defmodule Poker.CardTest do
  use ExUnit.Case
  doctest Poker.Card

  test "can only create cards with valid values and suites" do
    assert catch_error(Poker.Card.create(0, "abcd")) == :function_clause
    assert catch_error(Poker.Card.create(1, "abcd")) == :function_clause
    assert catch_error(Poker.Card.create(0, "Heart")) == :function_clause
  end
end
