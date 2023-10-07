defmodule Vitals do
  @moduledoc false
  @spec check_diagnostics() :: String.t() | integer()
  def check_diagnostics() do
    Vitals.DiagnosticTable.check_diagnostics(:pretty)
  end

  @spec check_diagnostics(Vitals.Formatter.format()) :: String.t() | integer()
  def check_diagnostics(format, opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    Vitals.DiagnosticTable.check_diagnostics(format, opts)
  end
end
