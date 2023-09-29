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

  def init(_opts) do
    children = [
      Vitals.DiagnosticTable
      # handlers supervisor
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
