defmodule Poker.Shuffle do
  alias Poker.Card
  alias Poker.Randomizer

  @spec shuffle_list_call(Card.deck(), (integer() -> integer()), integer()) :: Card.deck()
  @spec shuffle_list_call(Card.deck(), (integer() -> integer())) :: Card.deck()
  @spec shuffle_list_call(Card.deck()) :: Card.deck()
  def shuffle_list_call(deck, rng_gen \\ &Randomizer.next_xorshift64/1, state \\ Randomizer.deterministic_seed()) do
    shuffle(deck, [], rng_gen, state)
  end

  @spec shuffle(Card.deck(), Card.deck(), (integer() -> integer()), integer()) :: Card.deck()
  def shuffle([], acc, _rng_gen, _state), do: Enum.reverse(acc)

  @spec shuffle(Card.deck(), Card.deck(), (integer() -> integer()), integer()) :: Card.deck()
  def shuffle(deck, acc, rng_gen, state) do
    next_state = rng_gen.(state)
    index = Randomizer.modulo(next_state, length(deck))
    {el, remaining} = List.pop_at(deck, index)
    IO.inspect(state)

    shuffle(remaining, [el | acc], rng_gen, next_state)
  end

  @spec shuffle_deck((integer() -> integer()), integer()) :: Card.deck()
  @spec shuffle_deck() :: Card.deck()
  def shuffle_deck(rng_gen \\ &Randomizer.next_xorshift64/1, state \\ Randomizer.deterministic_seed()) do
    deck = Poker.Deck.generate()
    shuffle_list_call(deck, rng_gen, state)
  end
end
