defmodule Poker.Shuffle do
  @moduledoc """
  Defines functions to shuffle a deck of `Poker.Card`.
  """

  alias Poker.Card
  alias Poker.Randomizer

  @doc """
  Shuffles the given `deck` with `rng_gen` PRNG and some `state`. `rng_gen` defaults to
  `Poker.Randomizer.next_xorshift64/1` and `state` defaults to `1` if not provided.
  """
  @spec shuffle_list_call(Card.deck(), (integer() -> integer()), integer()) :: Card.deck()
  @spec shuffle_list_call(Card.deck(), (integer() -> integer())) :: Card.deck()
  @spec shuffle_list_call(Card.deck()) :: Card.deck()
  def shuffle_list_call(
        deck,
        rng_gen \\ &Randomizer.next_xorshift64/1,
        state \\ 1
      ) do
    shuffle(deck, [], rng_gen, state)
  end

  @spec shuffle(Card.deck(), Card.deck(), (integer() -> integer()), integer()) :: Card.deck()
  def shuffle([], acc, _rng_gen, _state), do: Enum.reverse(acc)

  @doc """
  Shuffles the `deck` with the given `rng_gen` PRNG and accumulates it in `acc`. `state` is for the
  current PRNG state
  """
  @spec shuffle(Card.deck(), Card.deck(), (integer() -> integer()), integer()) :: Card.deck()
  def shuffle(deck, acc, rng_gen, state) do
    next_state = rng_gen.(state)
    index = Randomizer.modulo(next_state, length(deck))
    {el, remaining} = List.pop_at(deck, index)
    IO.inspect(state)

    shuffle(remaining, [el | acc], rng_gen, next_state)
  end

  @doc """
  Generates and shuffles the `Poker.Card` deck and returns it. Can accept a `rng_gen` PRNG
  and a seed `state`. Defaults to `Poker.Randomizer.next_xorshift64/1` and `1` respectively
  """
  @spec shuffle_deck((integer() -> integer()), integer()) :: Card.deck()
  @spec shuffle_deck((integer() -> integer())) :: Card.deck()
  @spec shuffle_deck() :: Card.deck()
  def shuffle_deck(
        rng_gen \\ &Randomizer.next_xorshift64/1,
        state \\ 1
      ) do
    deck = Poker.Deck.generate()
    shuffle_list_call(deck, rng_gen, state)
  end
end
