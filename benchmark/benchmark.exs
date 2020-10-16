list = Enum.to_list(1..1_000_000)
map = list |> Enum.map(&to_string/1) |> Enum.with_index() |> Map.new()

{:ok, blist} = ExBencode.encode(list)
{:ok, bmap} = ExBencode.encode(map)

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

Benchee.run(
  %{
    "ExBencode decoding a list" => fn -> ExBencode.encode!(blist) end,
    "Bento decoding a list" => fn -> Bento.encode!(blist) end
  }
)

Benchee.run(
  %{
    "ExBencode decoding a map" => fn -> ExBencode.encode!(bmap) end,
    "Bento decoding a map"     => fn -> Bento.encode!(bmap) end
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
