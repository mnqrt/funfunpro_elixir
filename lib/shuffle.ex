defmodule Poker.Shuffle do
  alias Poker.Card
  alias Poker.Randomizer

  @spec shuffle_list_call(list(Card.t()), (integer() -> integer()), integer()) :: list(Card.t())
  @spec shuffle_list_call(list(Card.t()), (integer() -> integer())) :: list(Card.t())
  @spec shuffle_list_call(list(Card.t())) :: list(Card.t())
  def shuffle_list_call(deck, rng_gen \\ &Randomizer.next_xorshift64/1, state \\ Randomizer.deterministic_seed()) do
    # IO.inspect(deck)
    shuffle(deck, [], rng_gen, state)
  end

  @spec shuffle(list(Card.t()), list(Card.t()), (integer() -> integer()), integer()) :: list(Card.t())
  def shuffle([], acc, _rng_gen, _state), do: Enum.reverse(acc)

  @spec shuffle(list(Card.t()), list(Card.t()), (integer() -> integer()), integer()) :: list(Card.t())
  def shuffle(deck, acc, rng_gen, state) do
    next_state = rng_gen.(state)
    index = Randomizer.modulo(next_state, length(deck))
    {el, remaining} = List.pop_at(deck, index)
    IO.inspect(state)

    shuffle(remaining, [el | acc], rng_gen, next_state)
  end

  @spec shuffle_deck((integer() -> integer()), integer()) :: list(Card.t())
  @spec shuffle_deck() :: list(Card.t())
  def shuffle_deck(rng_gen \\ &Randomizer.next_xorshift64/1, state \\ Randomizer.deterministic_seed()) do
    deck = Poker.Deck.generate()
    shuffle_list_call(deck, rng_gen, state)
  end
end
