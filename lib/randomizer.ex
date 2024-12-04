defmodule Poker.Randomizer do
  @moduledoc """
  Defines PRNGs for shuffling a deck of `Poker.Card`
  """

  import Bitwise

  @doc """
  Get the current time in seconds.
  """
  @spec get_now() :: integer()
  def get_now(), do: System.os_time(:second)

  @doc """
  Get the current time forwarded by 1 day.
  """
  @spec get_tomorrow() :: integer()
  def get_tomorrow() do
    DateTime.now!("Etc/UTC") |> DateTime.shift(day: 1) |> DateTime.to_unix()
  end

  @doc """
  Defines the Xorshift64 PRNG
  """
  @spec next_xorshift64(integer()) :: integer()
  def next_xorshift64(state) do
    a = bxor(state, bsl(state, 13))
    b = bxor(a, bsr(a, 7))
    bxor(b, bsl(b, 17))
  end

  @doc """
  Defines a PRNG based on modular arithmetic
  """
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

  @doc """
  Returns the `value` in the `modulus` ring.
  """
  @spec modulo(integer(), integer()) :: integer()
  def modulo(value, modulus), do: rem(value, modulus)
end
