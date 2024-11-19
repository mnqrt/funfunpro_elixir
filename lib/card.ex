defmodule Poker.Card do

  @values Enum.to_list(1..13)
  @suites ["Spade", "Heart", "Diamond", "Club"]

  defstruct [:value, :suite]

  @type t :: %Poker.Card{value: integer(), suite: String.t()}
  @type deck :: [t]

  def values, do: @values
  def suites, do: @suites

  def create(value, suite) when value in @values and suite in @suites do
    %Poker.Card{value: value, suite: suite}
  end
end
