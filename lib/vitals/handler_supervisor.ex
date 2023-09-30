defmodule Vitals.HandlerSupervisor do
  @moduledoc """
  Supervisor for individual handlers
  """

  use Supervisor

  def start_link(handlers) do
    Supervisor.start_link(__MODULE__, handlers, name: __MODULE__)
  end

  def init(handlers) do
    handlers
    |> Enum.map(fn h ->
      {Vitals.DiagnosticServer, h}
    end)
    |> Supervisor.init(strategy: :one_for_one)
  end
end
