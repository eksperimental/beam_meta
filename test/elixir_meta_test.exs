defmodule ElixirMetaTest do
  use ExUnit.Case
  doctest ElixirMeta

  test "greets the world" do
    assert ElixirMeta.hello() == :world
  end
end
