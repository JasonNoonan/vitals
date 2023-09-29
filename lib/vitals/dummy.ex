defmodule Vitals.DummyHandler do
  alias Vitals.Diagnostic

  def init(_opts) do
    Diagnostic.new(status: :fatal)
  end
end
