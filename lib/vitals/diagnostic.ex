defmodule Vitals.Diagnostic do
  @type status :: :healthy | :degraded | :fatal

  @type timer_spec :: %{
          every: {non_neg_integer(), :second}
        }

  @type t :: %__MODULE__{
          status: status(),
          taken: DateTime.t(),
          assigns: map(),
          timer: timer_spec() | nil
        }

  @enforce_keys [:status, :taken, :assigns]
  defstruct [:status, :taken, :assigns, :timer]

  @doc """
  Create a `Diagnostic` and apply defaults.
  """
  def new(params) do
    params_with_defaults =
      params
      |> Map.new()
      |> Map.put_new(:taken, DateTime.utc_now())
      |> Map.put_new(:assigns, %{})

    struct!(__MODULE__, params_with_defaults)
  end

  @doc """
  Return if `Diagnostic` has a timer attached.
  """
  def timer?(%__MODULE__{timer: nil}), do: false
  def timer?(%__MODULE__{}), do: true

  @doc """
  Return if `Diagnostic` is in a fatal state.

  Fatal is a terminal state that a Handler will not recover from.
  """
  def fatal?(%__MODULE__{status: :fatal}), do: true
  def fatal?(%__MODULE__{status: _non_fatal}), do: false

  def next_run(%__MODULE__{timer: nil}), do: nil

  def next_run(%__MODULE__{timer: %{every: {unit, :second}}}) do
    :timer.seconds(unit)
  end
end
