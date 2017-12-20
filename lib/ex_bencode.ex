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
  """
  def decode(b)

  def decode(nil) do
    {:error, :not_bencoded_form}
  end

  def decode(s) do
    cond do
      String.match?(s, ~r/^i-?\d+e$/) -> {:ok, extract_int(s)}
      String.match?(s, ~r/^\d:.*$/) -> {:ok, extract_string(s)}
      true -> {:error, :not_bencoded_form}
    end
  end

  defp extract_int(s) do
    len = String.length(s)
    substr = String.slice(s, 1, (len - 2))
    {int, _} = Integer.parse(substr)
    int
  end

  defp extract_string(s) do
    [_, body] = String.split(s, ":", parts: 2)
    body
  end
end
