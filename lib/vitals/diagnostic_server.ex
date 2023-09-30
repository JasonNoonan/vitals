defmodule Vitals.DiagnosticServer do
  @moduledoc """
  Generic server for providing handler functionality
  """

  use GenServer
  alias Vitals.Diagnostic

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def child_spec(args) do
    id = Keyword.get(args, :id, __MODULE__)

    default = %{
      id: id,
      start: {__MODULE__, :start_link, [args]}
    }

    Supervisor.child_spec(default, [])
  end

  @impl GenServer
  def init(opts) do
    handler = opts[:handler]
    id = Keyword.get(opts, :id, handler)

    diagnostic =
      :telemetry.span(
        [:vitals, :diagnostic],
        %{},
        fn ->
          diagnostic =
            handler.init(opts)
            |> report_diagnostic(handler)
            |> maybe_schedule_follow_up()

          {diagnostic, %{handler: id, diagnostic: diagnostic}}
        end
      )

    {:ok, %{handler: handler, id: id, last_diagnostic: diagnostic}}
  end

  @impl GenServer
  def handle_info(:check, %{handler: handler, id: id, last_diagnostic: last_diagnostic} = state) do
    new_diagnostic =
      :telemetry.span(
        [:vitals, :diagnostic],
        %{},
        fn ->
          diagnostic =
            last_diagnostic
            |> handler.check()
            |> report_diagnostic(id)
            |> maybe_schedule_follow_up()

          {diagnostic, %{handler: handler, diagnostic: diagnostic}}
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
