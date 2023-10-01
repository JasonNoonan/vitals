defmodule Vitals.ControlledHandler do
  @behaviour Vitals.Handler
  alias Vitals.Diagnostic

  def check(last_diagnostic) do
    status = Agent.get(last_diagnostic.assigns.agent, fn status -> status end)
    %Diagnostic{last_diagnostic | status: status}
  end

  def init(%{id: id}) do
    {:ok, pid} = Agent.start_link(fn -> :healthy end, name: String.to_atom(id))

    Diagnostic.new(status: :healthy, timer: %{every: {5, :second}})
    |> Diagnostic.assign(agent: pid)
  end

  def set_status(agent, status) do
    Agent.update(agent, fn _state -> status end)
  end
end
