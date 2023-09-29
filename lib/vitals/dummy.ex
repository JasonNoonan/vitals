defmodule Vitals.DummyHandler do
  @behaviour Vitals.Handler
  alias Vitals.Diagnostic

  def check(last_diagnostic) do
    dbg()
    last_diagnostic
  end

  def init(_opts) do
    Diagnostic.new(status: :healthy, timer: %{every: {5, :second}})
  end
end
