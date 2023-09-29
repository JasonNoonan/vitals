defmodule VitalsTest do
  use ExUnit.Case
  doctest Vitals

  test "greets the world" do
    assert Vitals.hello() == :world
  end
end
