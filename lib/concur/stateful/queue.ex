defmodule Concur.Queue do
  @moduledoc """
  Stateful queue abstraction.

  Often it's necessary to deal with a stateful queue, this abstraction is built
  using both Agents and Erlang's `:queue` module.

  ## Examples

  For example, the following uses the Queue by pushing and popping elements from it:

      {:ok, queue} = Queue.start()

      Queue.push(queue, 1)
      Queue.push(queue, 2)
      Queue.push(queue, 3)

      Queue.pop(queue) # => {:value, 1}
      Queue.pop(queue) # => {:value, 2}
      Queue.pop(queue) # => {:value, 3}
      Queue.pop(queue) # => :empty
  """

  @type queue() :: Agent.agent()

  @spec start(GenServer.options()) :: Agent.on_start()
  def start(opts \\ []) do
    Agent.start(fn -> :queue.new() end, opts)
  end

  @spec start_link(GenServer.options()) :: Agent.on_start()
  def start_link(opts \\ []) do
    Agent.start_link(fn -> :queue.new() end, opts)
  end

  @spec push(queue(), term()) :: :ok
  def push(agent, item), do: Agent.update(agent, &:queue.in(item, &1))

  @spec pop(queue()) :: {:value, term()} | :empty
  def pop(agent), do: Agent.get_and_update(agent, &:queue.out(&1))

  @spec is_empty?(queue()) :: boolean()
  def is_empty?(agent), do: Agent.get(agent, &:queue.is_empty/1)

  @spec to_list(queue()) :: [term()]
  def to_list(agent), do: Agent.get(agent, &:queue.to_list/1)

  @spec stop(queue()) :: :ok
  def stop(queue), do: Agent.stop(queue)
end
