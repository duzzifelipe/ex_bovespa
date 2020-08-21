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
      name: "ExBovespa",
      dialyzer: [
        plt_add_apps: [
          :ex_unit,
          :mix,
          :erts
        ],
        ignore_warnings: ".dialyzer_ignore.exs",
        list_unused_filters: true
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.3.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0", runtime: false, allow_pre: false, only: [:dev, :test]},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end
end
