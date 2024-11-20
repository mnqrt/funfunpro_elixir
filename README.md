# FunfunproElixir
To see if the algorithm behaves the same as the previous (ts) code:

### Elixir
1. `iex -S mix`
2. `alias Poker.{Randomizer, Shuffle}`
3. `Shuffle.shuffle_deck(&Randomizer.next_xorshift64/1, 1)`
4. `Shuffle.shuffle_deck(Randomizer.next_mod(4), 1)`

### TypeScript
1. `ts-node src/utils/generateRandom.ts`


## Self Note

### `generate_hands`
```elixir
  def generate_hands(player_count) do
    fn deck ->
      {Enum.chunk_every(deck, 2) |> Enum.take(player_count), Enum.drop(deck, player_count * 2)}
    end
  end
```

`generate_hands(3)` akan mengembalikan fungsi yang menerima `deck`, setelahnya return `{[hand1, hand2, hand3], [kartu sisanya]}`.


Bagaimana caranya? pertama kita akan analisis
```elixir
Enum.chunk_every(deck, 2) |> Enum.take(player_count)
```

terlebih dahulu.

`Enum.chunk_every(deck, 2)` mengembalikan list yang isinya list (dengan size 2); Dengan kata lain, dipisah pisah. Contoh: 
```elixir
Enum.chunk_every([1,2,3,4,5,6], 2) = [[1,2], [3,4], [5,6]]
```
inner list yang sizenya 2 inilah yang kemudian akan menjadi hand. Tapi ini baru 1 hand, jika kita ingin mengambil sebanyak `player_count` hand, maka kita perlu ambil `player_count` elemen pertama dari list of listnya. Bagaimana caranya? Kita akan lihat bagian kanan dari kodenya yaitu
```elixir
|> Enum.take(player_count)
```

Pertama, apa yang dimaksud dengan `|>`? Jadi ini kurang lebih berperan sebagai builtin dari `pipe` pada kode typescript sebelumnya. Dengan kata lain, dia akan memproses fungsi di kiri lebih dahulu, lalu hasilnya akan dipass sebagai **parameter pertama** pada fungsi selanjutnya (Ini adalah default, tapi bisa dimodif)

Signature dari `Enum.take` adalah `Enum.take(enumerable, amount)`, yang mana parameter pertamanya adalah `enumerable`, tapi disini kita tulisnya `Enum.take(player_count)`. Kenapa begitu? Hal ini sebab nature dari `|>` yang akan "menaruh" hasil dari operasi/fungsi di kiri sebagai parameter pertama, lalu sisanya di shift ke kanan.

Sebagai summary:
```elixir
Enum.chunk_every(deck, 2) |> Enum.take(player_count)
```
ekuivalen dengan

```elixir
Enum.take(Enum.chunk_every(deck, 2), player_count)
```

Jadi sebenernya kitqa gak perlu pakai `|>` sama sekali, tapi inti utama dari functional programming bukanlah untuk membuat suatu kode menjadi "benar", tapi lebih ke bagaimana kita membuat kode kita mudah untuk di maintain dan dimodifikasi kedepannya. Karena Kalau kita kekeh makai `Enum.take(Enum.chunk_every(deck, 2), player_count)`, kodenya lebih sulit untuk dibaca, dan kalau misalkan ada penambahan, kita masih harus nambah2 lagi. 

Dari sini, kami merasa bahwa sintaks `|>` dan juga konsep fungsi pada elixir yang bisa menerima lebih dari 1 kemungkinan jumlah parameter, contoh: `shuffle_deck0 shuffle_deck/1 shuffle_deck/2` yang ternyata bisa menjadi jembatan bagi `|>` adalah hal yang cukup menarik, dan mungkin akan butuh beberapa lama waktu agar bisa menjadi intuitif.


### `shuffle`
```elixir
  def shuffle([], acc, _rng_gen, _state), do: Enum.reverse(acc)

  def shuffle(deck, acc, rng_gen, state) do
    next_state = rng_gen.(state)
    index = Randomizer.modulo(next_state, length(deck))
    {el, remaining} = List.pop_at(deck, index)
    IO.inspect(state)

    shuffle(remaining, [el | acc], rng_gen, next_state)
  end
```

pada dasarnya, `shuffle` adalah fungsi yang menerima 4 parameter `(deck, acc, rng_gen, state)` dengan deskripsi sebagai berikut:
1. deck: list yang ingin di shuffle (awalnya)
2. acc: akumulator, hal ini menjadi yang akan di return di base case. Didapatkan dari mengambil random elemen pada `deck`, dan `push_front` elemennya pada `acc`
3. rng_gen: fungsi yang menerima state, lalu akan memberikan state selanjutnya. 
4. state: state sekarang. (Note: pengambilan elemen "random" itu berdasarkan state)

Pada elixir, yang saya tangkap adalah mereka menghandle base case dengan `pattern matching`, yang artinya best practice di mereka yaitu bukan dengan early return seperti handling base case biasanya, tapi disini kita ngecek apakah `deck == []`, mirip dengan haskell. Hal lain yang bisa dinote adalah cara elixir memanggil referensi fungsi (misalkan dia di parameter, `rng_gen`), yaitu dengan `next_state = rng_gen.(state)`. Jadi sepertinya butuh waktu pembiasaan. `{el, remaining} = List.pop_at(deck, index)` juga salah satu contoh penerapan pattern matching.