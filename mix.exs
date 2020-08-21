defmodule ExBovespa.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_bovespa,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/duzzifelipe/ex_bovespa",
      homepage_url: "https://github.com/duzzifelipe/ex_bovespa",
      name: "ExBovespa"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end
end
