defmodule Poker.Randomizer do
  @moduledoc """
  Implements deterministic random number generation using Xorshift64.
  """

  import Bitwise

  def deterministic_seed(seed \\ 1), do: seed

  def next_xorshift64(state) do
    a = bxor(state, bsl(state, 13))
    b = bxor(a, bsr(a, 7))
    bxor(b, bsl(b, 17))
  end


  def next_mod(mod) do
    fn state ->
      big_mod = mod |> :erlang.bsl(1)
      if state + big_mod > 52 do
        rem(state, big_mod) + 1
      else
        state + big_mod
      end
    end
  end

  def modulo(value, modulus), do: rem(value, modulus)
end
