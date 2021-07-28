defmodule VhsTest do
  use ExUnit.Case
  doctest Vhs

  test "greets the world" do
    assert Vhs.hello() == :world
  end
end
