defmodule Vitals.Diagnostic do
  @moduledoc """
  `Diagnostic`s represent the result of `Handler` running a checkup on a
  dependency.

  `Diagnostic`s contain a `status` of the last run, a optional `timer` for
  when an additional check should be performed, as well as `assigns` to store
  any user state needed for the `Handler` to perform its checks.

  ## Status

  Status is used to define the health of the entity being monitored. Use
  `:fatal` to signify that something is unhealthy and will not be able to
  recover. Such as having invalid credetials or configuration. Otherwise a
  `Diagnostic` should be returned with `:healthy` or `:degraded`.
  """

  @typedoc """
  The status of a Diagnostic check.

  `:fatal` is considered terminal and a diagnostic will not be ran again when
  it is in this state. `:degraded` is used to represent an unhealthy state
  where there is a chance that it can become `:healthy`.
  """
  @type status :: :healthy | :degraded | :fatal

  @typedoc """
  Specifies when next diagnostic check should occur.

  When a `Diagnostic` is returned with a `timer_spec` these values will be used
  to schedule the next check.
  """
  @type timer_spec :: %{
    every: {non_neg_integer(), :second | :millisecond}
        }

  @type t :: %__MODULE__{
          status: status(),
          taken: DateTime.t(),
          assigns: map(),
          timer: timer_spec() | nil
        }

  @enforce_keys [:status, :taken, :assigns]
  defstruct [:status, :taken, :assigns, :timer]

  @spec new(keyword()) :: t()
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

  @spec timer?(t()) :: boolean()
  @doc """
  Return if `Diagnostic` has a timer attached.
  """
  def timer?(%__MODULE__{timer: nil}), do: false
  def timer?(%__MODULE__{}), do: true

  @spec fatal?(t()) :: boolean()
  @doc """
  Return if `Diagnostic` is in a fatal state.

  Fatal is a terminal state that a Handler will not recover from.
  """
  def fatal?(%__MODULE__{status: :fatal}), do: true
  def fatal?(%__MODULE__{status: _non_fatal}), do: false

  @spec next_run(t()) :: non_neg_integer() | nil
  @doc """
  Returns milliseconds until next check should happen for `Diagnostic`.

  If `Diagnostic` is not configured with a `t:timer_spec/0` nil will be
  returned.
  """
  def next_run(%__MODULE__{timer: %{every: {unit, :second}}}) do
    :timer.seconds(unit)
  end

  def next_run(%__MODULE__{timer: %{every: {unit, :millisecond}}}) do
    unit
  end

  def next_run(%__MODULE__{timer: nil}), do: nil
end
