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

alias Vitals.Handler

{:ok, _pid} =
  Vitals.Supervisor.start_link(
    handlers: [
      Handler.spec(mod: Vitals.DummyHandler, id: "handler01"),
      Handler.spec(mod: Vitals.DummyHandler, id: "handler02"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled01"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled02"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled03"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled04"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled05"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled06"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled07"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled08"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled09"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled10"),
      Handler.spec(mod: Vitals.ControlledHandler, id: "controlled11"),
    ]
  )
