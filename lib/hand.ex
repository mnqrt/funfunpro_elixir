defmodule Poker.Hand do
  alias Poker.Card
  alias Poker.Validator

  defstruct [:card1, :card2]

  @type t :: %Poker.Hand{
    card1: Card.t(),
    card2: Card.t()
  }

  def create(card1, card2) do
    Validator.validate_card(card1)
    Validator.validate_card(card2)

    %Poker.Hand{
      card1: card1,
      card2: card2
    }
  end

  def print_example_hand do
    card1 = Poker.Card.create(1, "Spade")
    card2 = Poker.Card.create(13, "Heart")
    hand = create(card1, card2)
    IO.inspect(hand, label: "Example Poker Hand")
  end
end

Poker.Hand.print_example_hand()
