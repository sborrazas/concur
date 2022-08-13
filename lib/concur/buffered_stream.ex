defmodule Concur.BufferedStream do
  @moduledoc """
  Producer/consumer implementation of a pre-processing stream, with a limited
  buffer size.
  """

  alias Concur.Semaphore, as: Sem

  @type opt() ::
          {:buffer_size, pos_integer()} | {:async?, boolean()} | {:timeout, non_neg_integer()}

  @spec map(Enumerable.t(), (Enum.element() -> any()), [opt()]) :: Enumerable.t()
  def map(enumerable, fun, opts) do
    timeout = Keyword.get(opts, :timeout, 5000)
    buffer_size = Keyword.fetch!(opts, :buffer_size)
    sync? = not Keyword.get(opts, :async?, false)
    queue = :queue.new()

    Stream.resource(
      fn ->
        processing = Sem.new(1)

        case StreamSplit.take_and_drop(enumerable, buffer_size) do
          {[], enumerable} ->
            {queue, enumerable, processing}

          {items, enumerable} ->
            queue =
              items
              |> Enum.map(&spawn_task(&1, fun, processing, sync?))
              |> Enum.reduce(queue, &:queue.in/2)

            {queue, enumerable, processing}
        end
      end,
      fn {queue, enumerable, processing} ->
        case :queue.out(queue) do
          {{:value, task}, queue} ->
            case StreamSplit.take_and_drop(enumerable, 1) do
              {[], enumerable} ->
                {[Task.await(task, timeout)], {queue, enumerable, processing}}

              {[item], enumerable} ->
                queue = :queue.in(spawn_task(item, fun, processing, sync?), queue)

                {[Task.await(task, timeout)], {queue, enumerable, processing}}
            end

          {:empty, queue} ->
            {:halt, {queue, enumerable, processing}}
        end
      end,
      fn {queue, _enumerable, processing} ->
        queue
        |> :queue.to_list()
        |> Enum.each(&Task.shutdown/1)

        Sem.stop(processing)
      end
    )
  end

  defp spawn_task(item, fun, processing, sync?) do
    Task.async(fn ->
      if sync?, do: Sem.wait(processing)
      result = fun.(item)
      if sync?, do: Sem.signal(processing)
      result
    end)
  end
end
