defmodule Poker.Shuffle do
  alias Poker.Randomizer

  def shuffle_list_call(deck, rng_gen \\ &Randomizer.next_xorshift64/1, state \\ Randomizer.deterministic_seed()) do
    shuffle(deck, [], rng_gen, state)
  end

  def shuffle([], acc, _rng_gen, _state), do: Enum.reverse(acc)

  def shuffle(deck, acc, rng_gen, state) do
    next_state = rng_gen.(state)
    index = Randomizer.modulo(next_state, length(deck))
    {el, remaining} = List.pop_at(deck, index)
    IO.inspect(state)

    shuffle(remaining, [el | acc], rng_gen, next_state)
  end

  def shuffle_deck(rng_gen \\ &Randomizer.next_xorshift64/1, state \\ 1) do
    deck = Poker.Deck.generate()
    shuffle_list_call(deck, rng_gen, state)
  end
end
