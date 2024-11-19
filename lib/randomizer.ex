defmodule Poker.Randomizer do
  import Bitwise

  def deterministic_seed(seed \\ 1), do: seed

  def next_xorshift64(state) do
    a = bxor(state, bsl(state, 13))
    b = bxor(a, bsr(a, 7))
    bxor(b, bsl(b, 17))
  end


  def next_mod(mod) do
    fn state ->
      if state + mod > 52 do
        rem(state, mod) + 1
      else
        state + mod
      end
    end
  end

  def modulo(value, modulus), do: rem(value, modulus)
end
