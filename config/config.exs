use Mix.Config

if Mix.env() == :test do
  config :tesla, adapter: Tesla.Mock

  config :ex_bovespa,
    parallelism: 1,
    stock_adapter_module: ExBovespa.Adapters.BovespaMock,
    broker_adapter_module: ExBovespa.Adapters.B3Mock,
    status_invest_adapter: ExBovespa.Adapters.StatusInvestMock
end
