defmodule ExBencode do
  @moduledoc """
  Documentation for ExBencode.
  """

  @doc """
  Decode the bencoded binary value.

  ## Examples

  Decoding integers

      iex> ExBencode.decode("i10e")
      {:ok, 10}

      iex> ExBencode.decode("i-10e")
      {:ok, -10}

    Scientific notation is **not** supported

      iex> ExBencode.decode("i1.5e7e")
      {:error, :unexpected_content, %{index: 5, unexpected: "7e"}}

  Decoding strings

      iex> ExBencode.decode("4:spam")
      {:ok, "spam"}

      iex> ExBencode.decode("4:too much spam")
      {:error, :unexpected_content, %{index: 6, unexpected: "much spam"}}

  Bytes are handled using the string type, with the preceding number
  representing the byte size, not the string length.

      iex> ExBencode.decode(<<?3, ?:, 1, 2, 3>>)
      {:ok, <<1, 2, 3>>}

      iex> ExBencode.decode("7:hełło")
      {:ok, "hełło"}

      iex> ExBencode.decode("5:hełło")
      {:error, :unexpected_content, %{index: 7, unexpected: <<130, 111>>}}

  Decoding lists

      iex> ExBencode.decode("le")
      {:ok, []}

      iex> ExBencode.decode("l4:spam4:eggse")
      {:ok, ["spam", "eggs"]}

  Decoding Dictionaries

      iex> ExBencode.decode("de")
      {:ok, %{}}

      iex> ExBencode.decode("d3:cow3:mooe")
      {:ok, %{"cow" => "moo"}}

      iex> ExBencode.decode("d8:shoppingl4:eggs4:milkee")
      {:ok, %{"shopping" => ["eggs", "milk"]}}
  """
  def decode(s) when is_binary(s) do
    case extract_next(s) do
      {:ok, body, ""} -> {:ok, body}
      # Fail if there's anything leftover after we parse
      {:ok, _, unexpected} ->
        {
          :error,
          :unexpected_content,
          %{
            index: byte_size(s) - byte_size(unexpected),
            unexpected: unexpected
          }
        }
      {:error, msg} -> {:error, msg}
      {:error, msg, details} -> {:error, msg, details}
    end
  end

  defp extract_next(<<"i", _rest :: bits>> = s), do: extract_int(s)


  defp extract_next(<<i, _rest :: bits>> = s) when i >= ?0 and i <= ?9 do
    with [len_bin | _] <- :binary.split(s, ":"),
         header_size <- byte_size(len_bin) + 1,
         str_and_rest <- after_n(s, header_size),
         {length, ""} <- Integer.parse(len_bin)
    do
      if byte_size(str_and_rest) < length do
        {:error, :invalid_string, %{expected_size: length, actual_size: byte_size(str_and_rest)}}
      else
        str = first_n(str_and_rest, length)
        rest = after_n(str_and_rest, length)

        if byte_size(str) != length do
          {:error, :invalid_string, %{expected_size: length, actual_size: byte_size(str)}}
        else
          {:ok, str, rest}
        end
      end
    else
      _ -> {:error, :invalid_string}
    end
  end


  defp extract_next(<<"l", _rest :: bits>> = s) do
    {"l", tail} = String.split_at(s, 1)
    extract_list_contents(tail)
  end

  defp extract_next(<<"d", tail :: bits>>) do
    with  {:ok, contents, rest} <- extract_list_contents(tail)
    do
      mapcontents = contents
                      |> Enum.chunk(2)
                      |> Enum.map(fn [a, b] -> {a, b} end)
                      |> Map.new
      {:ok, mapcontents, rest}
    else
      err -> err
    end
  end

  defp extract_next(_), do: {:error, :not_bencoded_form}

  defp extract_int(<<"i", rest :: bits>>) do
    extract_int(rest, [])
  end

  defp extract_int(_) do
    {:error, :invalid_integer}
  end

  defp extract_int(<<i, rest :: bits>>, acc) when (i >= ?0 and i <= ?9) or i == ?. or i == ?- do
    extract_int(rest, [i | acc])
  end

  defp extract_int(<<"e", _ :: bits>>, []) do
    {:error, :invalid_integer}
  end

  defp extract_int(<<"e", rest :: bits>>, acc) do
    {int, _} = acc |> Enum.reverse() |> IO.iodata_to_binary() |> Integer.parse()
    {:ok, int, rest}
  end

  defp extract_int(_, _) do
    {:error, :invalid_integer}
  end

  defp first_n(subject, n) when byte_size(subject) < n  do
    :error
  end

  defp first_n(subject, n) do
    :binary.part(subject, 0, n)
  end

  defp after_n(subject, n) when byte_size(subject) < n do
    :error
  end

  defp after_n(subject, n) do
    :binary.part(subject, n, byte_size(subject)-n)
  end

  defp extract_list_contents(<<b::bits>>) do
    extract_list_contents({:ok, [], b})
  end

  defp extract_list_contents({:ok, list, <<?e, rest::bits>>}) do
    {:ok, Enum.reverse(list), rest}
  end

  defp extract_list_contents({:ok, list, rest}) do
    with {:ok, next, rest} <- extract_next(rest)
    do extract_list_contents({:ok, [next|list], rest})
    else err -> err
    end
  end

  defprotocol Bencode do
    @fallback_to_any true
    @doc "Encode an erlang term."
    def encode(term)
  end

  defimpl Bencode, for: Integer do
    def encode(term) do
      {:ok, "i" <> Integer.to_string(term) <> "e"}
    end
  end

  defimpl Bencode, for: BitString do
    def encode(term) do
      len = Integer.to_string byte_size(term)
      {:ok, len <> ":" <> term}
    end
  end

  defimpl Bencode, for: List do
    def encode(term) do
      {:ok, "l" <> encode_contents(term) <> "e"}
    end

    defp encode_contents(term) when is_list(term) do
      Enum.join(for x <- term, {:ok, e} = Bencode.encode(x), do: e)
    end
  end

  defimpl Bencode, for: Map do
    def encode(term) do
      {:ok, "d" <> encode_contents(term) <> "e"}
    end

    defp encode_contents(term) when is_map(term) do
      term
      |> Map.to_list
      |> List.keysort(0)
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&encode_contents/1)
      |> Enum.join()
    end

    defp encode_contents(term) when is_list(term) do
      Enum.join(for x <- term, {:ok, e} = Bencode.encode(x), do: e)
    end
  end

  defimpl Bencode, for: Tuple do
    def encode(term) do
      term |> Tuple.to_list() |> Bencode.encode()
    end
  end

  defimpl Bencode, for: Any do
    def encode(term) do
      term |> to_string() |> Bencode.encode()
    end
  end

  @doc """
  Encode an erlang term.

  ## Examples

      iex> ExBencode.encode(1)
      {:ok, "i1e"}

      iex> ExBencode.encode("hi!")
      {:ok, "3:hi!"}

      iex> ExBencode.encode([])
      {:ok, "le"}

      iex> ExBencode.encode([1])
      {:ok, "li1ee"}

      iex> ExBencode.encode(%{})
      {:ok, "de"}

      iex> ExBencode.encode(%{"cow" => "moo"})
      {:ok, "d3:cow3:mooe"}

    Note that a keyword list counts as a list of lists, so convert keyword
    lists to maps before encoding. Otherwise, an empty keyword list
    could either be encoded as an empty list or an empty dict, and the
    library avoids making that kind of arbitrary decision.

      iex> ExBencode.encode([cow: "moo"])
      {:ok, "ll3:cow3:mooee"}

    Use `Enum.into/2` to convert a keyword list into a map

      iex> Enum.into [cow: "moo"], %{}
      %{cow: "moo"}

      iex> ExBencode.encode(%{cow: "moo"})
      {:ok, "d3:cow3:mooe"}


  """
  def encode(term) do
    Bencode.encode(term)
  end
end
