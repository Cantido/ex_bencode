defmodule ExBencode do
  @moduledoc """
  Documentation for ExBencode.
  """

  @doc """
  Decode the bencoded binary value.

  ## Examples

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

  """
  def decode(b)

  def decode(nil) do
    {:error, :not_bencoded_form}
  end

  def decode(s) do
    cond do
      String.match?(s, ~r/^i-?\d+e$/) -> {:ok, extract_int(s)}
      true -> {:error, :not_bencoded_form}
    end
  end

  defp extract_int(s) do
    len = String.length(s)
    substr = String.slice(s, 1, (len - 2))
    {int, _} = Integer.parse(substr)
    int
  end
end
