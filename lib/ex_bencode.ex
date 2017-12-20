defmodule ExBencode do
  @moduledoc """
  Documentation for ExBencode.
  """

  @doc """
  Decode the bencoded binary value.

  ## Examples

      iex> ExBencode.decode(nil)
      {:ok, nil}

      iex> ExBencode.decode("")
      {:ok, nil}

      iex> ExBencode.decode("i10e")
      {:ok, 10}

      iex> ExBencode.decode("i8001e")
      {:ok, 8001}

      iex> ExBencode.decode("i")
      {:error, :not_bencoded_form}

  """
  def decode(b)


  def decode(nil) do
    {:ok, nil}
  end

  def decode("i") do
    {:error, :not_bencoded_form}
  end

  def decode(s) do
    case String.length(s) do
      0 -> {:ok, nil}
      x when x <= 2 -> {:error, :not_bencoded_form}
      _ -> {:ok, extract_int(s)}
    end
  end

  defp extract_int(s) do
    len = String.length(s)
    substr = String.slice(s, 1, (len - 2))
    {int, _} = Integer.parse(substr)
    int
  end
end
