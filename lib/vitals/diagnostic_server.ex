defmodule Vitals.DiagnosticServer do
  @moduledoc """
  Generic server for providing handler functionality
  """

  use GenServer
  alias Vitals.Diagnostic
  alias Vitals.Handler

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def child_spec(%Handler.Spec{id: id} = spec) do
    default = %{
      id: id,
      start: {__MODULE__, :start_link, [spec]}
    }

    Supervisor.child_spec(default, [])
  end

  @impl GenServer
  def init(%Handler.Spec{} = spec) do
    {:ok, %{spec: spec, last_diagnostic: nil}, {:continue, :ok}}
  end

  @impl GenServer
  def handle_continue(:ok, %{spec: %{id: id, mod: mod} = spec} = state) do
    diagnostic =
      :telemetry.span(
        [:vitals, :diagnostic],
        %{},
        fn ->
          diagnostic =
            mod.init(spec)
            |> report_diagnostic(id)
            |> maybe_schedule_follow_up()

          {diagnostic, %{handler: id, diagnostic: diagnostic}}
        end
      )

    {:noreply, %{state | last_diagnostic: diagnostic}}
  end

  @impl GenServer
  def handle_info(:check, %{spec: %{id: id, mod: mod}, last_diagnostic: last_diagnostic} = state) do
    new_diagnostic =
      :telemetry.span(
        [:vitals, :diagnostic],
        %{},
        fn ->
          diagnostic =
            last_diagnostic
            |> mod.check()
            |> report_diagnostic(id)
            |> maybe_schedule_follow_up()

          {diagnostic, %{handler: id, diagnostic: diagnostic}}
        end
      )

    {:noreply, %{state | last_diagnostic: new_diagnostic}}
  end

  #################################################
  # HELPERS
  #################################################

  defp report_diagnostic(diagnostic, handler_id) do
    Vitals.DiagnosticTable.add_diagnostic(handler_id, diagnostic)
    diagnostic
  end

  defp maybe_schedule_follow_up(diagnostic) do
    [
      not Diagnostic.fatal?(diagnostic),
      Diagnostic.timer?(diagnostic)
    ]
    |> Enum.all?()
    |> if do
      Process.send_after(self(), :check, Diagnostic.next_run(diagnostic))
      diagnostic
    else
      diagnostic
    end
  end
end
