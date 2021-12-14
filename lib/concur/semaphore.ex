defmodule Concur.Semaphore do
  @moduledoc """
  Simple GenServer-based semaphores implementation, with the full semaphore
  functions `P` (`wait`) and `V` (`signal`).
  """

  use GenServer

  @type limit() :: non_neg_integer()

  @opaque t() :: pid()

  @spec new(limit()) :: t()
  def new(limit) do
    {:ok, pid} = GenServer.start_link(__MODULE__, limit)

    pid
  end

  @doc """
  Asynchronously increment the value of the semaphore by `1`.
  """
  @spec signal(t()) :: :ok
  def signal(sem), do: GenServer.cast(sem, :signal)

  @doc """
  Synchronously wait for the semaphore to be available. Decrement the semaphore
  by `1` once it is.
  """
  @spec wait(t()) :: :ok
  def wait(sem), do: GenServer.call(sem, :wait, :infinity)

  @doc """
  Stops the semaphore process.
  """
  @spec stop(t()) :: :ok
  def stop(sem), do: GenServer.cast(sem, :stop)

  @impl true
  def init(limit) do
    {:ok, {limit, :queue.new()}}
  end

  @impl true
  def handle_call(:wait, from, {0, queue}) do
    {:noreply, {0, :queue.in(from, queue)}}
  end

  def handle_call(:wait, _from, {limit, queue}) do
    {:reply, :ok, {limit - 1, queue}}
  end

  @impl true
  def handle_cast(:signal, {limit, queue}) do
    case :queue.out(queue) do
      {{:value, pid}, queue} ->
        GenServer.reply(pid, :ok)
        {:noreply, {limit, queue}}

      {:empty, queue} ->
        {:noreply, {limit + 1, queue}}
    end
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end
end
