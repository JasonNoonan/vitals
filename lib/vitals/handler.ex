defmodule Vitals.Handler do
  @moduledoc """
  A behaviour for defining Handlers that report `Diagnostic`'s against a
  dependency.
  """
  alias Vitals.Diagnostic

  @callback init(any()) :: Diagnostic.t()
  @callback check(last_diagnostic :: Diagnostic.t()) :: Diagnostic.t()

  @optional_callbacks check: 1
end
