defmodule BencodePerformanceTest do
  use ExUnit.Case, async: true

  describe "Performance" do
    test "time performance of linux mint 18.3 torrent" do
      file = File.read!("test/linuxmint-18.3-cinnamon-64bit.iso.torrent")
      time_per_decode = perftest(file, 10000)

      IO.puts("Avg time to decode: #{time_per_decode} μsec")
    end
  end

  defp perftest(file, iterations) do
    chunk_size = 100
    chunk_count = div(iterations, chunk_size)

    stream = Task.async_stream(Range.new(0, chunk_count), fn _ -> time_to_decode(file, chunk_size) end)
    total_time = Enum.reduce(stream, 0, fn {:ok, num}, acc -> num + acc end)

    total_time / iterations
  end

  defp time_to_decode(file, iterations) do
    times = for _ <- Range.new(0, iterations) do
      {time, _} = :timer.tc(fn -> ExBencode.decode(file) end)
      time
    end
    Enum.sum(times)
  end
end
