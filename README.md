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


Kenapa kita membuat fungsi suites()? Padahal kan kita bisa langsung import variabel suite aja? Gunanya adalah supaya kita bisa lakukan piping.

Sebagai contoh, berikut adalah fungsi yang mengembalikan list semua card, namun dalam bentuk yang formatted (string).

```elixir
  @spec format_card(Card.t()) :: String.t()
  def format_card(card) do
    card.suite <> " " <> Integer.to_string(card.value)
  end

  def print_deck() do
    Deck.generate() |> Enum.map(&format_card/1)
  end
```

Disini, fungsi generate() sebenarnya bisa digantikan dengan variabel saja, sebab nilainya akan selalu konstan (yaitu kumpulan semua card), namun dengan dibuatnya menjadi fungsi, hal ini mempermudah penggunaan piping, sehingga kita dapat memasukkan hasil dari semua card (tipe data card), kedalam map sebagai parameter pertama. Sehingga akan dihasilkan kumpulan semua kartu, namunyang telah diformat oleh `map`

### `count_num`
```elixir
  @spec count_num(map(), integer()) :: non_neg_integer()
  defp count_num(value_counts, count) do
    Enum.count(value_counts, fn {_, %{count: ^count}} -> true; _ -> false end)
  end
```

Pada `hand_ranking.ex`, sebelumnya, fungsi-fungsi seperti `one_pair?`, `two_pair?`, `three_of_a_kind?`, serta `four_of_a_kind?` melakukan hal yang sama, yaitu menghitung ada berapa banyak value pada `value_counts` yang `count` nya `2` untuk `pair`, `3` untuk `three of a kind`, dan `4` untuk `four of a kind`. Untuk menghindari duplikasi dan mempersimpel kode, kami membuat fungsi privat `count_num` yang akan menghitung ada berapa banyak value yang banyak `count`nya tergantung input dari fungsinya.

### `full_house?`
```elixir
  @spec full_house_checker(list(non_neg_integer())) :: boolean()
  defp full_house_checker(counts), do: counts == [2, 3] or counts == [3, 3]

  @spec full_house?(map()) :: boolean()
  def full_house?(value_counts) do
    Enum.filter(value_counts, fn {_, %{count: c}} -> c in [2, 3] end)
    |> Enum.map(fn {_, %{count: c}} -> c end)
    |> Enum.sort()
    |> full_house_checker()
  end
```

Fungsi ini sekilas cukup sulit dibaca, terutama untuk yang tidak terbiasa dengan sintaks `Elixir`, namun jika dibedah perlahan, fungsi ini ternyata cukup simpel.

```elixir
Enum.filter(value_counts, fn {_, %{count: c}} -> c in [2, 3] end)
```

Bagian ini melakukan filter terhadap `value_counts` untuk mengambil semua entry dimana `count` nya bernilai 2 atau 3. Misal `value_counts` seperti di bawah.
```elixir
%{
  2 => %{count: 1, suite_rank: 4},
  10 => %{count: 2, suite_rank: 4},
  11 => %{count: 2, suite_rank: 4},
  12 => %{count: 1, suite_rank: 3},
  13 => %{count: 1, suite_rank: 3}
}
```
Hasil filtrasi dari `value_counts` di atas adalah `[{10, %{count: 2, suite_rank: 4}}, {11, %{count: 2, suite_rank: 4}}]`

```elixir
|> Enum.map(fn {_, %{count: c}} -> c end)
```

Hasil filtrasi diteruskan ke sebuah fungsi yang akan mengambil hanya value dari `count` nya saja. Misal dengan hasil filtrasi di atas, hasil piping ke fungsi tersebut akan mengembalikan `[2, 2]`.

```elixir
|> Enum.sort()
```

Fungsi ini seharusnya sudah cukup jelas. Return value dari fungsi sebelumnya akan di sort secara ascending (default Elixir).

```elixir
|> full_house_checker()
```

Bagian ini akan memasukkan hasil sorting ke fungsi privat `full_house_checker` yang akan mengecek apakah hasil sorting merupakan list `[2, 3]` atau `[3, 3]` saja.

### `is_flush?`
```elixir
  @spec is_flush?(Card.deck()) :: boolean()
  def is_flush?(sorted_cards) do
    sorted_cards
    |> Enum.group_by(&(&1.suite))
    |> Enum.any?(fn {_, grouped_cards} -> length(grouped_cards) >= 5 end)
  end
```

Fungsi ini mungkin lebih mudah dibaca dibanding fungsi `full_house?` sebelumnya, namun terdapat bagian yang cukup menarik, yaitu `|> Enum.group_by(&(&1.suite))`. Bagian ini sebenarnya mengambil `sorted_cards` dan akan melakukan grouping berdasarkan `suite` dari card-card yang ada di `sorted_cards`. Misal terdapat `sorted_cards` sebagai berikut.
```elixir
[
  %Poker.Card{value: 13, suite: "Heart"},
  %Poker.Card{value: 12, suite: "Heart"},
  %Poker.Card{value: 12, suite: "Spade"},
  %Poker.Card{value: 10, suite: "Spade"},
  %Poker.Card{value: 5, suite: "Club"},
  %Poker.Card{value: 5, suite: "Heart"},
  %Poker.Card{value: 5, suite: "Spade"}
]
```

Ketika `sorted_cards` ini dimasukkan ke fungsi `Enum.groupby` dengan fungsi yang mengambil `suite` dari card yang ada di dalamnya, akan dihasilkan grouping sebagai berikut.
```elixir
%{
  "Club" => [%Poker.Card{value: 5, suite: "Club"}],
  "Heart" => [
    %Poker.Card{value: 13, suite: "Heart"},
    %Poker.Card{value: 12, suite: "Heart"},
    %Poker.Card{value: 5, suite: "Heart"}
  ],
  "Spade" => [
    %Poker.Card{value: 12, suite: "Spade"},
    %Poker.Card{value: 10, suite: "Spade"},
    %Poker.Card{value: 5, suite: "Spade"}
  ]
}
```

Hasil grouping ini nantinya akan dilihat apakah ada yang panjangnya lebih dari atau sama dengan 5 untuk menentukan apakah hand ini flush atau tidak.

### `is_straight?`
```elixir
  @spec is_straight?(Card.deck()) :: boolean()
  def is_straight?(sorted_cards) do
    sorted_cards
    |> Enum.map(&(&1.value))
    |> Enum.uniq()
    |> Enum.sort()
    |> consecutive_count(5)
  end

  @spec consecutive_count(list(non_neg_integer()), non_neg_integer()) :: boolean()
  defp consecutive_count(values, count) do
    case values do
      [a, b | rest] when b == a + 1 -> consecutive_count([b | rest], count - 1)
      [_ | rest] when count > 1 -> consecutive_count(rest, 5)
      _ when count <= 1 -> true
      _ -> false
    end
  end
```

Fungsi `is_straight?` juga jauh lebih mudah dimengerti dibandingkan dengan fungsi `full_house?` di atas. Fungsi ini pada dasarnya mengambil semua `value` dari card yang ada pada `sorted_cards` kemudian diambil value-value yang unik dan di sort secara ascending (default). Hasil sorting ini nantinya akan dimasukkan ke fungsi `consecutive_count` yang akan mengecek apakah elemen kedua dengan elemen pertama hanya memiliki perbedaan sebesar 1.

###  `compare_hands`
```elixir
  @spec compare_card_value(Card.t(), Card.t()) :: integer()
  def compare_card_value(%Card{value: value_a, suite: suite_a}, %Card{value: value_b, suite: suite_b}) do
    suite_rank = HandRanking.suite_rank()

    cond do
      value_a != value_b -> value_a - value_b
      true -> suite_rank[suite_a] - suite_rank[suite_b]
    end
  end

  @spec rank_hand(Card.deck()) :: %{rank: 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10, high_card: Card.t()}
  def rank_hand(cards) do
    sorted_cards = sort_cards(cards)

    rank = sorted_cards |> HandRanking.hand_rank()
    %{rank: rank, high_card: hd(sorted_cards)}
  end

  @spec compare_hands(Board.t(), Hand.t(), Hand.t()) :: String.t()
  def compare_hands(board, %Hand{card1: card1a, card2: card2a}, %Hand{card1: card1b, card2: card2b}) do
    full_hand1 = [card1a, card2a, board.card1, board.card2, board.card3, board.card4, board.card5]
    full_hand2 = [card1b, card2b, board.card1, board.card2, board.card3, board.card4, board.card5]

    task1 = Task.async(fn -> rank_hand(full_hand1) end)
    task2 = Task.async(fn -> rank_hand(full_hand2) end)

    rank1 = Task.await(task1)
    rank2 = Task.await(task2)
    comparison = compare_card_value(rank1.high_card, rank2.high_card)

    cond do
      rank1.rank > rank2.rank -> "Hand1"
      rank2.rank > rank1.rank -> "Hand2"
      comparison > 0 -> "Hand1"
      comparison < 0 -> "Hand2"
      true -> "Tie"
    end
  end
```

Fungsi ini pada dasarnya akan melakukan comparison antara 2 `Hand` melalui fungsi `rank_hand` secara asinkronus lalu mengecek antara `high_card` melalui `compare_card_value` dan baru di cek yang mana yang lebih besar. Block `cond` berlaku seperti block `if` yang memiliki banyak kasus, namun membuat kasus-kasus tersebut lebih mudah dibaca dengan menggunakan banyak `if`.
