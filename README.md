# ExBencode

[![Hex.pm](https://img.shields.io/hexpm/v/ex_bencode)](https://hex.pm/packages/ex_bencode/)
![Elixir CI](https://github.com/Cantido/ex_bencode/workflows/Elixir%20CI/badge.svg)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg)](https://github.com/RichardLitt/standard-readme)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](code_of_conduct.md)

An Elixir library for encoding and decoding BitTorrent's bencoding.

## Installation

The package can be installed by adding `ex_bencode` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_bencode, "~> 2.0.1"}
  ]
end
```

Package docs can be found at [https://hexdocs.pm/ex_bencode](https://hexdocs.pm/ex_bencode).

## Usage

Just give `ExBencode.decode/1` a binary.
It returns a success or error tuple.

```elixir
iex> ExBencode.decode("i10e")
{:ok, 10}
```

Give `ExBencode.encode/1` any Elixir term.
It returns a success or error tuple as well.

```elixir
iex> ExBencode.encode("hi!")
{:ok, "3:hi!"}
```

The bang versions of these functions, `encode!/1` and `decode!/1`,
return the value without an error tuple, but will raise if there is an error.

To customize how your structs serialize, implement the `Bencode` protocol.

```elixir
defimpl Bencode, for: MyStruct do
  def encode(term) do
    term |> Map.from_struct() |> ExBencode.encode()
  end
end
```

## Benchmarks

A benchmark comparing this library's performance against [`Bento`](https://github.com/folz/bento) is given in the `benchmarks/` directory.
Run it using `mix run`

```sh
mix run benchmark/benchmark.exs
```

Results on my machine show that this library is just a teensy bit faster than Bento.

## Maintainer

This project was developed by [Rosa Richter](https://github.com/Cantido).
You can get in touch with her on [Keybase.io](https://keybase.io/cantido).

## Contributing

Questions and pull requests are more than welcome.
I follow Elixir's tenet of bad documentation being a bug,
so if anything is unclear, please [file an issue](https://github.com/Cantido/ex_bencode/issues/new)!
Ideally, my answer to your question will be in an update to the docs.

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for all the details you could ever want about helping me with this project.

Note that this project is released with a Contributor [Code of Conduct](code_of_conduct.md).
By participating in this project you agree to abide by its terms.


## License

MIT License

Copyright 2020 Rosa Richter.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
