defmodule Poker.Hand do
  alias Poker.Card
  alias Poker.Validator

  @enforce_keys [:card1, :card2]
  defstruct [:card1, :card2]

  @type t :: %Poker.Hand{
    card1: Card.t(),
    card2: Card.t()
  }

  @spec create(Card.t(), Card.t()) :: Poker.Hand.t()
  def create(card1, card2) do
    Validator.validate_card(card1)
    Validator.validate_card(card2)

    %Poker.Hand{
      card1: card1,
      card2: card2
    }
  end

  @spec print_example_hand() :: any()
  def print_example_hand do
    card1 = Card.create(1, "Spade")
    card2 = Card.create(13, "Heart")
    hand = create(card1, card2)
    IO.inspect(hand, label: "Example Poker Hand")
  end
end

Poker.Hand.print_example_hand()
