defmodule Vitals do
  @spec check_diagnostics() :: String.t()
  def check_diagnostics() do
    Vitals.DiagnosticTable.check_diagnostics(:pretty)
  end

  @spec check_diagnostics(Vitals.Formatter.format()) :: String.t()
  defdelegate check_diagnostics(format), to: Vitals.DiagnosticTable
end
