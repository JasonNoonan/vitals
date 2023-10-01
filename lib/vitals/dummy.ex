defmodule Vitals.DummyHandler do
  @behaviour Vitals.Handler
  alias Vitals.Diagnostic

  def check(last_diagnostic) do
    %Diagnostic{last_diagnostic | timer: nil}
  end

  def init(spec) do
    dbg(spec.id)

    status =
      if spec.id == "handler1" do
        :degraded
      else
        :healthy
      end

    Diagnostic.new(status: status, timer: %{every: {5, :second}})
  end
end
