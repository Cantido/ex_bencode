list = Enum.to_list(1..100_000)
map = list |> Enum.map(&to_string/1) |> Enum.with_index() |> Map.new()

Benchee.run(
  %{
    "ExBencode encoding a list" => fn -> ExBencode.encode!(list) end,
    "Bento encoding a list" => fn -> Bento.encode!(list) end
  }
)

Benchee.run(
  %{
    "ExBencode encoding a map" => fn -> ExBencode.encode!(map) end,
    "Bento encoding a map"     => fn -> Bento.encode!(map) end
  }
)

file = File.read!("test/linuxmint-18.3-cinnamon-64bit.iso.torrent")
{:ok, meta} = ExBencode.decode(file)

Benchee.run(%{
  "ExBencode decoding a torrent" => fn -> ExBencode.decode(file) end,
  "Bento decoding a torrent"     => fn -> Bento.decode(file) end
}, memory_time: 2, parallel: 2)

Benchee.run(%{
  "ExBencode encoding a torrent" => fn -> ExBencode.encode(meta) end,
  "Bento encoding a torrent"     => fn -> Bento.encode(meta) end
}, memory_time: 2, parallel: 2)
