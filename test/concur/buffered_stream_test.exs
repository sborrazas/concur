defmodule Concur.BufferedStreamTest do
  alias Concur.BufferedStream

  use ExUnit.Case

  # 10ms
  @instantly 10

  doctest BufferedStream

  test "it processes all items" do
    assert [2, 3, 4] = 1..3 |> BufferedStream.map(&(&1 + 1), buffer_size: 2) |> Enum.to_list()
  end

  test "it runs all tasks in order" do
    self = self()

    assert [2, 3, 4] =
             1..3
             |> BufferedStream.map(
               fn i ->
                 Process.send(self, {:block, i}, [])
                 Process.sleep(@instantly)
                 Process.send(self, {:unblock, i}, [])

                 i + 1
               end,
               buffer_size: 2
             )
             |> Enum.to_list()

    assert {:block, 1} = msg()
    assert {:unblock, 1} = msg()
    assert {:block, 2} = msg()
    assert {:unblock, 2} = msg()
    assert {:block, 3} = msg()
    assert {:unblock, 3} = msg()
    refute_received :_
  end

  test "when async, it runs all async tasks synchronously" do
    self = self()

    assert [2, 3, 4, 5] =
             1..4
             |> BufferedStream.map(
               fn i ->
                 Process.send(self, {:block, i}, [])
                 Process.sleep(@instantly * i)
                 Process.send(self, {:unblock, i}, [])

                 i + 1
               end,
               buffer_size: 2,
               async?: true
             )
             |> Enum.to_list()

    assert {:block, 1} = msg()
    assert {:block, 2} = msg()
    assert {:block, 3} = msg()
    assert {:unblock, 1} = msg()
    assert {:block, 4} = msg()
    assert {:unblock, 2} = msg()
    assert {:unblock, 3} = msg()
    assert {:unblock, 4} = msg()
    refute_received :_
  end

  defp msg do
    receive do
      msg -> msg
    after
      10_000 -> flunk("No message received")
    end
  end
end
