
defmodule BencodePerformanceTest do
  use ExUnit.Case, async: true
  import Benchee

  describe "Performance" do
    test "time performance of linux mint 18.3 torrent" do
      file = File.read!("test/linuxmint-18.3-cinnamon-64bit.iso.torrent")
      {:ok, meta} = ExBencode.decode(file)

      Benchee.run(%{
        "ExBencode" => fn -> ExBencode.decode(file) end,
        "Bento"     => fn -> Bento.decode(file) end
      }, memory_time: 2, parallel: 2)

      Benchee.run(%{
        "ExBencode" => fn -> ExBencode.encode(meta) end,
        "Bento"     => fn -> Bento.encode(meta) end
      }, memory_time: 2, parallel: 2)
    end
  end
end
