defmodule Vitals.DiagnosticFormatter do
  @moduledoc """
  Formatter for `Vitals.DiagnosticTable.State`.
  """
  
  alias Vitals.DiagnosticFormatter
  alias Vitals.DiagnosticTable.State

  @typedoc """
  Format to return `Vitals.DiagnosticTable.State`.

    * `io` - raw results
    * `pretty` - pretty print results to std out
    * `http` - state as http status code
    * `exit_code` - states as exit code
  """
  @type format :: :io | :pretty | :http | :exit_code

  def format(%State{} = state, :io) do
    DiagnosticFormatter.IO.format(state, :io)
  end

  def format(%State{} = state, :pretty) do
    DiagnosticFormatter.IO.format(state, :pretty)
  end

  def format(%State{status: :healthy}, :exit_code) do
    0
  end

  def format(%State{status: _non_healthy}, :exit_code) do
    127
  end

  def format(%State{status: :healthy}, :http) do
    200
  end

  def format(%State{status: _non_healthy}, :http) do
    503
  end
end
