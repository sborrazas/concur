defmodule Concur.QueueTest do
  alias Concur.Queue

  use ExUnit.Case

  doctest Queue

  test "it behaves like a stateful queue" do
    assert {:ok, queue} = Queue.start()

    assert :ok = Queue.push(queue, 1)
    assert :ok = Queue.push(queue, 2)
    assert :ok = Queue.push(queue, 3)

    # => {:value, 1}
    assert {:value, 1} = Queue.pop(queue)
    # => {:value, 2}
    assert {:value, 2} = Queue.pop(queue)
    # => {:value, 3}
    assert {:value, 3} = Queue.pop(queue)
    # => :empty
    assert :empty = Queue.pop(queue)
    assert :ok = Queue.stop(queue)
  end
end
