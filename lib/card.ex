defmodule Poker.Card do

  @values Enum.to_list(1..13)
  @suites ["Spade", "Heart", "Diamond", "Club"]

  @enforce_keys [:value, :suite]
  defstruct [:value, :suite]

  @type t :: %Poker.Card{value: integer(), suite: String.t()}
  @type deck :: [t]

  @spec values() :: [1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13]
  def values, do: @values

  @spec suites() :: [String.t()]
  def suites, do: @suites

  @spec create(1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13, String.t()) :: Poker.Card.t()
  def create(value, suite) when value in @values and suite in @suites do
    %Poker.Card{value: value, suite: suite}
  end
end

defimpl String.Chars, for: Poker.Card do
  @spec to_string(Poker.Card.t()) :: String.t()
  def to_string(card) do
    "#{card.suite} #{card.value}"
  end
end
