FROM elixir:1.13

# Install hex
RUN mix local.hex --force

# Install rebar
RUN mix local.rebar --force
