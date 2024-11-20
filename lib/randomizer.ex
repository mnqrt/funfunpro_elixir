defmodule Poker.Randomizer do
  import Bitwise

  @spec deterministic_seed(integer()) :: integer()
  @spec deterministic_seed() :: integer()
  def deterministic_seed(seed \\ get_now()), do: seed

  @spec get_now() :: integer()
  def get_now(), do: System.os_time(:second)

  @spec get_tomorrow() :: integer()
  def get_tomorrow() do
    DateTime.now!("Etc/UTC") |> DateTime.shift(day: 1) |> DateTime.to_unix()
  end

  @spec next_xorshift64(integer()) :: integer()
  def next_xorshift64(state) do
    a = bxor(state, bsl(state, 13))
    b = bxor(a, bsr(a, 7))
    bxor(b, bsl(b, 17))
  end

@spec next_mod(integer()) :: (integer() -> integer())
  def next_mod(mod) do
    fn state ->
      if state + mod > 52 do
        rem(state, mod) + 1
      else
        state + mod
      end
    end
  end

  @spec modulo(integer(), integer()) :: integer()
  def modulo(value, modulus), do: rem(value, modulus)
end
