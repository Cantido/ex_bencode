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

  defp extract_next(s) when is_binary(s) do
    case s do
      <<"i", _rest :: binary>> -> extract_int(s)
      <<i, _rest :: binary>> when i >= ?0 and i <= ?9 -> extract_string(s)
      <<"l", _rest :: binary>> -> extract_list(s)
      <<"d", _rest :: binary>> -> extract_dict(s)
      _ -> {:error, :not_bencoded_form}
    end
  end

  defp extract_int(s) when is_binary(s) do
    with [substr | rest] <- String.split(s, ~r/i|e/, parts: 2, trim: true),
         {int, _} <- Integer.parse(substr)
    do
      case rest do
        [] -> {:ok, int, ""}
        _ -> {:ok, int, hd(rest)}
      end
    else
      _err -> {:error, :invalid_integer}
    end
  end

  defp extract_string(s) when is_binary(s) do
    with [lenstr, rest] <- String.split(s, ":", parts: 2),
         {length, _} <- Integer.parse(lenstr),
         {str, rest} <- binary_split(rest, length)
    do
      if byte_size(str) != length do
        {:error, :invalid_string, %{expected_size: length, actual_size: byte_size(str)}}
      else
        {:ok, str, rest}
      end
    else
      _ -> {:error, :invalid_string}
    end
  end

  defp binary_split(binary, position) when is_binary(binary) and byte_size(binary) <= position do
    {binary, ""}
  end

  defp binary_split(binary, position) when is_binary(binary) and position >= 0 do
    tailsize = byte_size(binary) - position
    head = binary_part(binary, 0, position)
    tail = binary_part(binary, position, tailsize)
    {head, tail}
  end

  defp extract_list(s) when is_binary(s) do
    {"l", tail} = String.split_at(s, 1)
    extract_list_contents({:ok, [], tail})
  end

  defp extract_dict(s) when is_binary(s) do
    with  {"d", tail} <- String.split_at(s, 1),
          {:ok, contents, rest} <- extract_list_contents({:ok, [], tail})
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

  defp extract_list_contents({:ok, list, rest}) when is_list(list) and is_binary(rest) do
    # Build the list in reverse, then reverse it at the very end.
    # This lets us prepend entries to the list, which is much faster.
    if String.starts_with?(rest, "e") do
      {"e", afterlist} = String.split_at(rest, 1)
      {:ok, Enum.reverse(list), afterlist}
    else
      with {:ok, next, rest} <- extract_next(rest)
      do extract_list_contents({:ok, [next|list], rest})
      else err -> err
      end
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
  def encode(term)

  def encode(term) when is_integer(term) do
    {:ok, "i" <> Integer.to_string(term) <> "e"}
  end

  def encode(term) when is_binary(term) do
    len = Integer.to_string byte_size(term)
    {:ok, len <> ":" <> term}
  end

  def encode(term) when is_atom(term) do
    encode(Atom.to_string(term))
  end

  def encode(term) when is_list(term) do
    {:ok, "l" <> encode_contents(term) <> "e"}
  end

  def encode(term) when is_tuple(term) do
    encode(Tuple.to_list(term))
  end

  def encode(term) when is_map(term) do
    ts = term |> Map.to_list |> List.keysort(0)
    encoded_ts = for t <- ts, e = encode_contents(t), do: e

    {:ok, "d" <> Enum.join(encoded_ts) <> "e"}
  end

  defp encode_contents(term) when is_list(term) do
    Enum.join(for x <- term, {:ok, e} = encode(x), do: e)
  end

  defp encode_contents(term) when is_tuple(term) do
    encode_contents(Tuple.to_list(term))
  end
end
