list = Enum.to_list(1..100_000)
map = list |> Enum.map(&to_string/1) |> Enum.with_index() |> Map.new()

Benchee.run(
  %{
    "ex_bencode encoding a list" => fn -> ExBencode.encode!(list) end,
    "bento encoding a list" => fn -> Bento.encode!(list) end
  }
)

IO.puts ""

Benchee.run(
  %{
    "ex_bencode encoding a map" => fn -> ExBencode.encode!(map) end,
    "bento encoding a map" => fn -> Bento.encode!(map) end
  }
)
