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
  @type call_opts :: keyword()

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, Vitals)
    GenServer.start_link(__MODULE__, opts, name: Module.concat(opts[:name], DiagnosticTable))
  end

  @spec add_diagnostic(handler :: module(), Diagnostic.t(), call_opts()) :: true
  @doc """
  Add `diagnostic` result for `handler` to DiagnosticTable.
  """
  def add_diagnostic(handler, diagnostic, opts \\ []) do
    :ets.insert(table_name(opts), {handler, diagnostic})
  end

  @spec check_diagnostics(format :: Vitals.Formatter.format(), call_opts()) ::
          String.t() | integer()
  @doc """
  Output current diagnostic state in `format`.
  """
  def check_diagnostics(format, opts \\ []) do
    handler_diagnostics = :ets.tab2list(table_name(opts))

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
  def init(opts) do
    :ets.new(table_name(opts), [:named_table, :public, read_concurrency: true])

    initial_handler_diagnostics =
      Enum.map(opts[:handlers], fn %Handler.Spec{id: id} -> {id, nil} end)

    :ets.insert(table_name(opts), initial_handler_diagnostics)

    {:ok, nil}
  end

  defp table_name(opts) do
    prefix = Keyword.get(opts, :name, Vitals)
    Module.concat(prefix, DiagnosticTable)
  end
end
