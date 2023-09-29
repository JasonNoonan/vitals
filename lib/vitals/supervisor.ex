defmodule Vitals.Supervisor do
  @moduledoc """
  ```elixir
  {
    Vitals.Supervisor,
    handlers: [
      StripeHandler,
      SalesforceHandler,
      EctoHandler
    ]
  }
  ```
  """
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    children = [
      Vitals.DiagnosticTable,
      {Vitals.HandlerSupervisor, opts[:handlers]}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
