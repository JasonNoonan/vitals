{:ok, _pid} =
  Vitals.Supervisor.start_link(
    handlers: [
      Vitals.DummyHandler
    ]
  )
