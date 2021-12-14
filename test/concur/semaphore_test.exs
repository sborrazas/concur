defmodule Concur.SemaphoreTest do
  alias Concur.Semaphore

  use ExUnit.Case

  # 10ms
  @instantly 10

  doctest Semaphore

  test "it doesn't wait when semaphore is immediately available" do
    sem = Semaphore.new(1)
    task = Task.async(fn -> Semaphore.wait(sem) end)
    assert {:ok, :ok} = Task.yield(task, @instantly)
  end

  test "it waits when semaphore is not available" do
    sem = Semaphore.new(1)

    assert :ok = Semaphore.wait(sem)

    task = Task.async(fn -> Semaphore.wait(sem) end)
    assert nil == Task.yield(task, @instantly)
  end

  test "it doesn't wait for semaphore with more than one available" do
    sem = Semaphore.new(3)

    task1 = Task.async(fn -> Semaphore.wait(sem) end)
    assert {:ok, :ok} = Task.yield(task1, @instantly)

    task2 = Task.async(fn -> Semaphore.wait(sem) end)
    assert {:ok, :ok} = Task.yield(task2, @instantly)
  end

  test "it stops the semaphore" do
    sem = Semaphore.new(3)

    :ok = Semaphore.stop(sem)
  end
end
