defmodule TelemetryHandler do
  def handle_event([:vitals, :diagnostic, _start_stop], _measurements, _context, _config) do
    dbg()
  end
end

# :telemetry.attach_many(
#   "vitals_handler",
#   [
#     [:vitals, :diagnostic, :start],
#     [:vitals, :diagnostic, :stop]
#   ],
#   &TelemetryHandler.handle_event/4,
#   nil
# )

{:ok, _pid} =
  Vitals.Supervisor.start_link(
    handlers: [
      {Vitals.DummyHandler, id: "handler1"},
      {Vitals.DummyHandler, id: "handler2"}
    ]
  )
