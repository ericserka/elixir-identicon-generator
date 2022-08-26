defmodule IdenticonTest do
  use ExUnit.Case
  doctest Identicon

  test "generate the Identicon" do
    assert Identicon.main("ogtreasure") == :ok
  end
end
