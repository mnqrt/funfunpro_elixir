# FunfunproElixir
To see if the algorithm behaves the same as the previous (ts) code:

### Elixir
1. `iex -S mix`
2. `alias Poker.{Randomizer, Shuffle}`
3. `Shuffle.shuffle_deck(&Randomizer.next_xorshift64/1, 1)`
4. `Shuffle.shuffle_deck(Randomizer.next_mod(4), 1)`

### TypeScript
1. `ts-node src/utils/generateRandom.ts`
