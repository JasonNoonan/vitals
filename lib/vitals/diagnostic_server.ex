defmodule Vitals.DiagnosticServer do
  @moduledoc """
  Generic server for providing handler functionality
  """

  use GenServer
  alias Vitals.Diagnostic

  def start_link(handler) do
    GenServer.start_link(__MODULE__, handler)
  end

  @impl GenServer
  def init(handler) do
    diagnostic =
      :telemetry.span(
        [:vitals, :diagnostic],
        %{},
        fn ->
          diagnostic =
            handler.init([])
            |> report_diagnostic(handler)
            |> maybe_schedule_follow_up()

          {diagnostic, %{handler: handler, diagnostic: diagnostic}}
        end
      )

    {:ok, %{handler: handler, last_diagnostic: diagnostic}}
  end

  @impl GenServer
  def handle_info(:check, %{handler: handler, last_diagnostic: last_diagnostic} = state) do
    new_diagnostic =
      :telemetry.span(
        [:vitals, :diagnostic],
        %{},
        fn ->
          diagnostic =
            last_diagnostic
            |> handler.check()
            |> report_diagnostic(handler)
            |> maybe_schedule_follow_up()

          {diagnostic, %{handler: handler, diagnostic: diagnostic}}
        end
      )

    {:noreply, %{state | last_diagnostic: new_diagnostic}}
  end

  #################################################
  # HELPERS
  #################################################

  defp report_diagnostic(diagnostic, handler) do
    Vitals.DiagnosticTable.add_diagnostic(handler, diagnostic)
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
