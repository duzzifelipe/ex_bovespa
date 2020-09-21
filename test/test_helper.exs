# Application mocks
Application.ensure_all_started(:mox)
Mox.defmock(ExBovespa.Adapters.BovespaMock, for: ExBovespa.Adapters.BovespaBehaviour)
Mox.defmock(ExBovespa.Adapters.B3Mock, for: ExBovespa.Adapters.B3Behaviour)

ExUnit.start()
