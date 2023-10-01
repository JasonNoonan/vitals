defmodule Vitals.Handler do
  @moduledoc """
  A behaviour for defining Handlers that report `Diagnostic`'s against a
  dependency.
  """
  alias Vitals.Diagnostic

  defmodule Spec do
    @enforce_keys [:id, :mod]
    defstruct [:id, :mod]
  end

  def spec(opts) do
    struct!(__MODULE__.Spec, opts)
  end

  @callback init(any()) :: Diagnostic.t()
  @callback check(last_diagnostic :: Diagnostic.t()) :: Diagnostic.t()

  @optional_callbacks check: 1
end
