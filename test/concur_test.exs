defmodule ConcurTest do
  use ExUnit.Case
  doctest Concur

  test "greets the world" do
    assert Concur.hello() == :world
  end
end
