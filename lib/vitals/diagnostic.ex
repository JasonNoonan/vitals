defmodule Vitals.Diagnostic do
  @type status :: :healthy | :degraded | :fatal

  @type t :: %__MODULE__{
          status: status(),
          taken: DateTime.t(),
          assigns: map()
        }

  @enforce_keys [:status, :taken, :assigns]
  defstruct [:status, :taken, :assigns]

  def new(params) do
    params_with_defaults =
      params
      |> Map.new()
      |> Map.put_new(:taken, DateTime.utc_now())
      |> Map.put_new(:assigns, %{})

    struct!(__MODULE__, params_with_defaults)
  end
end
