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
      {:error, :not_bencoded_form}

  Decoding strings

      iex> ExBencode.decode("4:spam")
      {:ok, "spam"}

      iex> ExBencode.decode("4:too much spam")
      {:error, :not_bencoded_form}

  Bytes are handled using the string type, with the preceding number
  representing the byte size, not the string length.

      iex> ExBencode.decode(<<?3, ?:, 1, 2, 3>>)
      {:ok, <<1, 2, 3>>}

      iex> ExBencode.decode("7:hełło")
      {:ok, "hełło"}

      iex> ExBencode.decode("5:hełło")
      {:error, :not_bencoded_form}

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
  def decode(b)

  def decode(s) do
    case extract_next(s) do
      {:ok, body, ""} -> {:ok, body}
      # Fail if there's anything leftover after we parse
      {:ok, _, _} -> {:error, :not_bencoded_form}
      {:error, msg} -> {:error, msg}
    end
  end

  defp extract_next(s) do
    cond do
      is_nil(s) -> {:error, :not_string}
      not String.valid?(s) -> {:error, :not_string}
      String.match?(s, ~r/^i-?\d+e/) -> extract_int(s)
      String.match?(s, ~r/^\d:/) -> extract_string(s)
      String.match?(s, ~r/^l.*e/) -> extract_list(s)
      String.match?(s, ~r/^d.*e/) -> extract_dict(s)
      true -> {:error, :not_bencoded_form}
    end
  end

  defp extract_int(s) do
    [substr | rest] = String.split(s, ~r/i|e/, parts: 2, trim: true)
    {int, _} = Integer.parse(substr)
    case rest do
      [] -> {:ok, int, ""}
      _ -> {:ok, int, hd(rest)}
    end
  end

  defp extract_string(s) do
    [lenstr, rest] = String.split(s, ":", parts: 2)
    {length, _} = Integer.parse lenstr
    {str, rest} = binary_split(rest, length)
    if byte_size(str) != length do
      {:error, :not_bencoded_form}
    else
      {:ok, str, rest}
    end
  end

  defp binary_split(binary, position) do
    if byte_size(binary) <= position do
      {binary, ""}
    else
      tailsize = byte_size(binary) - position
      head = binary_part(binary, 0, position)
      tail = binary_part(binary, position, tailsize)
      {head, tail}
    end
  end

  defp extract_list(s) do
    {"l", tail} = String.split_at(s, 1)
    extract_list_contents({:ok, [], tail})
  end

  defp extract_dict(s) do
    {"d", tail} = String.split_at(s, 1)
    {:ok, contents, rest} = extract_list_contents({:ok, [], tail})
    mapcontents = contents
                    |> Enum.chunk(2)
                    |> Enum.map(fn [a, b] -> {a, b} end)
                    |> Map.new
    {:ok, mapcontents, rest}
  end

  defp extract_list_contents({:ok, list, rest}) do
    if String.starts_with?(rest, "e") do
      {"e", afterlist} = String.split_at(rest, 1)
      {:ok, list, afterlist}
    else
      with {:ok, next, rest} <- extract_next(rest)
      do extract_list_contents({:ok, list ++ [next], rest})
      else err -> err
      end
    end
  end
end
