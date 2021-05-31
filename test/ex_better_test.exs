defmodule ExBetterTest do
  use ExUnit.Case
  doctest ExBetter

  test "greets the world" do
    assert ExBetter.hello() == :world
  end
end
