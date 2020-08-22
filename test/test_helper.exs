# Application mocks
Application.ensure_all_started(:mox)
Mox.defmock(ExBovespa.Adapters.BovespaMock, for: ExBovespa.Adapters.BovespaBehaviour)

ExUnit.start()
