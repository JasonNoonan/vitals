defmodule Vitals.DummyHandler do
  alias Vitals.Diagnostic

  def check(last_diagnostic) do
    IO.inspect("Yo bud")
    last_diagnostic
  end

  def init(_opts) do
    Diagnostic.new(status: :healthy, timer: %{every: {5, :second}})
  end
end
