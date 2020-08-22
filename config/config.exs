use Mix.Config

if Mix.env() == :test do
  config :tesla, adapter: Tesla.Mock

  config :ex_bovespa,
    parallelism: 1,
    adapter_module: ExBovespa.Adapters.BovespaMock
end
