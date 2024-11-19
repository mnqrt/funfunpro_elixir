defmodule Poker.HandBoardGenerator do
  alias Poker.{Hand, Board}

  def generate_hands(player_count) do
    fn deck ->
      {Enum.chunk_every(deck, 2) |> Enum.take(player_count), Enum.drop(deck, player_count * 2)}
    end
  end

  def generate_board do
    fn [card1, card2, card3, card4, card5 | rest] ->
      {Board.create(card1, card2, card3, card4, card5), rest}
    end
  end
end
