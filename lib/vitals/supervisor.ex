defmodule Vitals.Supervisor do
  @moduledoc """
  ```elixir
  # in application.ex or root supervisor
  {
    Vitals.Supervisor,
    name: MyVitals,
    handlers: [
      Vitals.Handler.spec(
        id: "ecto"
        mod: EctoHandler
      ),
      Vitals.Handler.spec(
        id: "ecto-readonly"
        mod: EctoHandler
      ),
      Vitals.Handler.spec(
        id: "stripe",
        mod: StripeHandler
      )
    ]
  }
  ```
  """
  use Supervisor

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, Vitals)

    if handlers_valid?(opts[:handlers]) do
      Supervisor.start_link(__MODULE__, opts, name: Module.concat(opts[:name], Supervisor))
    else
      raise ArgumentError, "Each Vitals.Handler.Spec must have unique id"
    end
  end

  def init(opts) do
    handlers = opts[:handlers]

    children = [
      {Vitals.DiagnosticTable, handlers: handlers, name: opts[:name]},
      {Vitals.HandlerSupervisor, handlers: handlers, name: opts[:name]}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  defp handlers_valid?(handlers) do
    handlers
    |> Enum.uniq_by(&Map.get(&1, :id))
    |> length()
    |> Kernel.==(length(handlers))
  end
end
