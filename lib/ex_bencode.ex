defmodule ExBencode do
  @moduledoc """
  Documentation for ExBencode.
  """

  @doc """
  Decode the bencoded binary value.

  ## Examples

  Decoding integers

      iex> ExBencode.decode(nil)
      {:error, :not_bencoded_form}

      iex> ExBencode.decode("")
      {:error, :not_bencoded_form}

      iex> ExBencode.decode("i10e")
      {:ok, 10}

      iex> ExBencode.decode("i-10e")
      {:ok, -10}

      iex> ExBencode.decode("i8001e")
      {:ok, 8001}

      iex> ExBencode.decode("i")
      {:error, :not_bencoded_form}

      iex> ExBencode.decode("abcdef")
      {:error, :not_bencoded_form}

  Decoding strings

      iex> ExBencode.decode("4:spam")
      {:ok, "spam"}

      iex> ExBencode.decode("4:too much spam")
      {:error, :not_bencoded_form}

  Decoding lists

      iex> ExBencode.decode("le")
      {:ok, []}

      iex> ExBencode.decode("li10ee")
      {:ok, [10]}

      iex> ExBencode.decode("l4:spame")
      {:ok, ["spam"]}

      iex> ExBencode.decode("l4:spam4:eggse")
      {:ok, ["spam", "eggs"]}

      iex> ExBencode.decode("li10e4:eggse")
      {:ok, [10, "eggs"]}

  Decoding Dictionaries

    iex> ExBencode.decode("de")
    {:ok, %{}}

    iex> ExBencode.decode("d3:cow3:mooe")
    {:ok, %{"cow" => "moo"}}
  """
  def decode(b)

  def decode(nil) do
    {:error, :not_bencoded_form}
  end

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
    {str, rest} = String.split_at(rest, length)
    {:ok, str, rest}
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
      {:ok, next, rest} = extract_next(rest)
      extract_list_contents({:ok, list ++ [next], rest})
    end
  end
end
