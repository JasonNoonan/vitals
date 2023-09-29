defmodule Vitals do
  @spec check_diagnostics(Vitals.Formatter.format()) :: String.t()
  defdelegate check_diagnostics(format), to: Vitals.DiagnosticTable
end
