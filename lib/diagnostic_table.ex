defmodule Vitals.DiagnosticTable do
  use GenServer
  @table __MODULE__

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec add_diagnostic(module(), struct()) :: true
  def add_diagnostic(handler, diagnostic) do
    :ets.insert(@table, {handler, diagnostic})
  end

  @impl GenServer
  def init(_opts) do
    :ets.new(@table, [:named_table, :public, read_concurrency: true])

    {:ok, nil}
  end
end
