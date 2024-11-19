defmodule Poker.Shuffle do
  alias Poker.Randomizer

  def shuffle(deck, rng_gen \\ &Randomizer.next_xorshift64/1, state \\ Randomizer.deterministic_seed()) do
    shuffle_deck(deck, [], rng_gen, state)
  end

  defp shuffle_deck([], acc, _rng_gen, _state), do: Enum.reverse(acc)

  defp shuffle_deck(deck, acc, rng_gen, state) do
    next_state = rng_gen.(state)
    index = Randomizer.modulo(next_state, length(deck))
    {el, remaining} = List.pop_at(deck, index)

    shuffle_deck(remaining, [el | acc], rng_gen, next_state)
  end
end
