# Concur

Concurrency and streams utilities.

This library embeds multiple modules for dealing with concurrency and
Elixir streams. Including:

* [Semaphores](lib/concur/semaphore.ex)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `concur` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:concur, "~> 0.1.0"}
  ]
end
```

## Usage

The `Concur.Semaphore` provides a full semaphores implementation for it to be
used by either concurrent or synchronous code. It contains the two semaphore
primitives: `wait` and `signal`. Here's an example:

```elixir
alias Concur.Semaphore, as: Sem

sem = Sem.new(1)

# Process 1
Sem.wait() # => Proceeds to obtain the semaphore and continue executing

# Process 2
Sem.wait() # => Blocks until the semaphore is unblocked

# Process 1
Sem.signal() # => Unblocks semaphore. Process 2 continues executing
```

### Buffered stream

The `Concur.BufferedStream` provides way to map enumerable values in advance up to a certain amount of values (`buffer_size: 4` option).

These values can also be loaded asynchronously (with `async?: true` option), meaning we don't have to wait for the previous value to be computed to calculate the next one.

```elixir
alias Concur.BufferedStream, as: BS

[1, 2, 3]
|> BufferedStream.map(fn i ->
  # really long function that will take time to compute
  # which will be executed in advance for up to 10 values
end, buffer_size: 10)
|> Enum.map(&IO.inspect/1)

[1, 2, 3]
|> BufferedStream.map(fn i ->
  # ...
end, buffer_size: 10, async?: true)
```

## LICENSE

See [LICENSE](LICENSE)
