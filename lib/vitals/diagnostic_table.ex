defmodule Vitals.DiagnosticTable do
  alias Vitals.Diagnostic
  alias Vitals.DiagnosticFormatter
  alias Vitals.Handler

  defmodule State do
    @moduledoc """
    High level state of diagnostics derived from all diagnostic handlers.

    ## Fields

      * `status`: derived state based on all handlers
      * `diagnostics`: all handlers and their latest diagnostic
    """
    @type t :: %__MODULE__{
            status: :init | Vitals.Diagnostic.status(),
            diagnostics: [{handler :: module(), Vitals.Diagnostic.t()}]
          }

    @enforce_keys [:status, :diagnostics]
    defstruct [:status, :diagnostics]
  end

  use GenServer
  @table __MODULE__

  def start_link(handlers) do
    GenServer.start_link(__MODULE__, handlers, name: __MODULE__)
  end

  @spec add_diagnostic(handler :: module(), Diagnostic.t()) :: true
  @doc """
  Add `diagnostic` result for `handler` to DiagnosticTable.
  """
  def add_diagnostic(handler, diagnostic) do
    :ets.insert(@table, {handler, diagnostic})
  end

  @doc """
  Output current diagnostic state in `format`.
  """
  def check_diagnostics(format) do
    handler_diagnostics = :ets.tab2list(@table)

    status =
      Enum.reduce_while(handler_diagnostics, :healthy, fn
        {_handler_name, %Diagnostic{status: :fatal}}, _accum ->
          {:halt, :fatal}

        {_handler_name, nil}, _accum ->
          {:cont, :init}

        {_handler_name, %Diagnostic{status: :degraded}}, _accum ->
          {:halt, :degraded}

        {_handler_name, _diagnostic}, accum ->
          {:cont, accum}
      end)

    %State{
      status: status,
      diagnostics: handler_diagnostics
    }
    |> DiagnosticFormatter.format(format)
  end

  @impl GenServer
  def init(handler_specs) do
    :ets.new(@table, [:named_table, :public, read_concurrency: true])

    initial_handler_diagnostics =
      Enum.map(handler_specs, fn %Handler.Spec{id: id} -> {id, nil} end)

    :ets.insert(@table, initial_handler_diagnostics)

    {:ok, nil}
  end
end
