defmodule Vitals.DiagnosticServer do
  @moduledoc """
  Generic server for providing handler functionality
  """

  use GenServer

  def start_link(handler) do
    GenServer.start_link(__MODULE__, handler)
  end

  def init(handler) do
    diagnostic = handler.init([])
    Vitals.DiagnosticTable.add_diagnostic(handler, diagnostic)
    {:ok, diagnostic}
  end
end
