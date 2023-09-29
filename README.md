# Vitals


## Plan

```elixir
# in application.ex or root supervisor
{
  Vitals.Supervisor,
  handlers: [
    StripeHandler,
    SalesforceHandler,
    EctoHandler
  ]
}

```

```elixir
# getting diagnostics in router
Vitals.check_diagnostics(:http) # :http | :exit | :io | :io_pretty

# getting diagnostics in iex
Vitals.check_diagnostics(:io_pretty) # :http | :exit | :io | :io_pretty
```


```yaml
# getting diagnostics in kubernetes command
spec:
  containers:
    livenessProbe:
      exec:
        command:
          - /app/bin/my-app
          - eval
          - "Vitals.check_diagnostics(:exit)"
```

```elixir
# writing a handler
defmodule MyApp.Vitals.Handler do
  @behaviour Vitals.Handler
  alias Vitals.Diagnostic

  @impl Vitals.Handler
  def check(las_diagnostic) do
    # how you do the check
    %Diagnostic{}
  end

  @impl Vitals.Handler
  def init(_opts) do
    %Diagnostic{timer: {5, :second}}
  end

  def handle_info(:check, _from, state) do
    {:noreply, check(state)}
  end
end
```


If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `vitals` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vitals, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/vitals>.

