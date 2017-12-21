defmodule ExBencodeTest do
  use ExUnit.Case
  doctest ExBencode

  test "bad bencode" do
    assert ExBencode.decode(nil) == {:error, :not_string}
    assert ExBencode.decode(1) == {:error, :not_string}
    assert ExBencode.decode("") == {:error, :not_bencoded_form}
    assert ExBencode.decode("abcdef") == {:error, :not_bencoded_form}
  end

  test "integer decoding" do
    assert ExBencode.decode("i10e") == {:ok, 10}
    assert ExBencode.decode("i-10e") == {:ok, -10}
    assert ExBencode.decode("i8001e") == {:ok, 8001}

    assert ExBencode.decode("i") == {:error, :not_bencoded_form}
    assert ExBencode.decode("ie") == {:error, :not_bencoded_form}
  end

  test "string decoding" do
    assert ExBencode.decode("0:") == {:ok, ""}
    assert ExBencode.decode("1:a") == {:ok, "a"}
    assert ExBencode.decode("1:ab") == {:error, :not_bencoded_form}
  end

  test "list decoding" do
    assert ExBencode.decode("le") == {:ok, []}
    assert ExBencode.decode("li10ee") == {:ok, [10]}
    assert ExBencode.decode("l4:spame") == {:ok, ["spam"]}
    assert ExBencode.decode("l1e") == {:error, :not_bencoded_form}
    assert ExBencode.decode("lee") == {:error, :not_bencoded_form}
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
