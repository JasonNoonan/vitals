defmodule Vitals.HandlerSupervisor do
  @moduledoc """
  Supervisor for individual handlers
  """

  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: Module.concat(opts[:name], HandlerSupervisor))
  end

  def init(opts) do
    opts[:handlers]
    |> Enum.map(fn handler_spec ->
      {Vitals.DiagnosticServer, handler_spec: handler_spec, name: opts[:name]}
    end)
    |> Supervisor.init(strategy: :one_for_one)
  end
end
