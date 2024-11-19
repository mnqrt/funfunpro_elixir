defmodule Poker.Board do
  alias Poker.Card
  alias Poker.Validator

  defstruct [:card1, :card2, :card3, :card4, :card5]

  @type t :: %Poker.Board{
    card1: Card.t(),
    card2: Card.t(),
    card3: Card.t(),
    card4: Card.t(),
    card5: Card.t()
  }

  def create(card1, card2, card3, card4, card5) do
    Validator.validate_card(card1)
    Validator.validate_card(card2)
    Validator.validate_card(card3)
    Validator.validate_card(card4)
    Validator.validate_card(card5)


    %Poker.Board{
      card1: card1,
      card2: card2,
      card3: card3,
      card4: card4,
      card5: card5
    }
  end

  def example_print_board do
    card1 = Poker.Card.create(1, "Spade")
    card2 = Poker.Card.create(13, "Heart")
    card3 = Poker.Card.create(9, "Diamond")
    card4 = Poker.Card.create(3, "Club")
    card5 = Poker.Card.create(4, "Heart")

    IO.inspect(%Poker.Board{
      card1: card1,
      card2: card2,
      card3: card3,
      card4: card4,
      card5: card5
    })
  end
end

Poker.Board.example_print_board()
