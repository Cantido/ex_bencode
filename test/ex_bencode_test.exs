defmodule ExBencodeTest do
  use ExUnit.Case
  doctest ExBencode

  test "decoding a torrent file" do
    {:ok, contents} = File.read "test/linuxmint-18.3-cinnamon-64bit.iso.torrent"

    refute contents == nil

    {:ok, data} = ExBencode.decode(contents)

    assert data["announce"] == "https://torrents.linuxmint.com/announce.php"
    assert data["created by"] == "Transmission/2.84 (14307)"
    assert data["creation date"] == 1511774851
    assert data["encoding"] == "UTF-8"

    info = data["info"]
    assert info["length"] == 1899528192
    assert info["name"] == "linuxmint-18.3-cinnamon-64bit.iso"
    assert info["piece length"] == 1048576

    pieces = info["pieces"]
    pieces_size = byte_size(pieces)
    hashes_count = pieces_size / 20
    assert hashes_count == 1812
  end


  test "bad bencode" do
    assert ExBencode.decode(nil) == {:error, :not_binary}
    assert ExBencode.decode(1) == {:error, :not_binary}
    assert ExBencode.decode("") == {:error, :not_bencoded_form}
    assert ExBencode.decode("abcdef") == {:error, :not_bencoded_form}
  end

  test "integer decoding" do
    assert ExBencode.decode("i10e") == {:ok, 10}
    assert ExBencode.decode("i-10e") == {:ok, -10}
    assert ExBencode.decode("i8001e") == {:ok, 8001}

    assert ExBencode.decode("i") == {:error, :invalid_integer}
    assert ExBencode.decode("ie") == {:error, :invalid_integer}
  end

  test "string decoding" do
    assert ExBencode.decode("0:") == {:ok, ""}
    assert ExBencode.decode("1:a") == {:ok, "a"}
    assert ExBencode.decode("1:ab") == {:error, :unexpected_content, %{unexpected: "b", index: 3}}
    assert ExBencode.decode("2:a") == {:error, :invalid_string, %{actual_size: 1, expected_size: 2}}
  end

  test "byte string decoding" do
    assert ExBencode.decode(<<?3, ?:, 1, 2, 3>>) == {:ok, <<1, 2, 3>>}
    assert ExBencode.decode("d4:info" <> <<?3, ?:, 1, 2, 3>> <> "e")
            == {:ok, %{"info" => <<1, 2, 3>>}}
  end

  test "list decoding" do
    assert ExBencode.decode("le") == {:ok, []}
    assert ExBencode.decode("li10ee") == {:ok, [10]}
    assert ExBencode.decode("l4:spame") == {:ok, ["spam"]}
    assert ExBencode.decode("l1e") == {:error, :invalid_string}
    assert ExBencode.decode("lee") == {:error, :unexpected_content, %{index: 2, unexpected: "e"}}
  end

  test "dictionary decoding" do
    assert ExBencode.decode("de") == {:ok, %{}}

    assert ExBencode.decode("d3:cow3:mooe")
            == {:ok, %{"cow" => "moo"}}
  end

  test "nested containers" do
    assert ExBencode.decode("d8:shoppingl4:eggs4:milkee")
            == {:ok, %{"shopping" => ["eggs", "milk"]}}

    assert ExBencode.decode("l6:headerd5:class9:paragraphee")
            == {:ok, ["header", %{"class" => "paragraph"}]}
  end
end
