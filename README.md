# ExBovespa

The goal of this library is to provide an easy interface for other elixir applications to retrieve a list of all stocks listed on B3, including their code, ISIN, name and type.

## Installation

Add `ex_bovespa` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_bovespa, "~> 0.1.0"}
  ]
end
```

## Usage

To have the entire list of Bovespa listed stocks, just call:

```elixir
{:ok, result} = ExBovespa.stock_list()
```

A sample of the data structure returned inside the list from `stock_list` is:

```elixir
[
  %ExBovespa.Structs.Stock{
    company_code: "IBOV",
    detail_list: [
      %ExBovespa.Structs.StockDetail{
        code: "IBOV11",
        isin_code: "BRIBOVINDM18"
      },
      ...
      ...
    ],
    name: "INDICE BOVESPA",
    short_name: "IBOVESPA"
  },
  ...
  ...
]
```

This function takes some time to return (since it fetches more than a thousand rows) so it is not recommended to run it frequently on your code, just to populate your own database.

## Documentation

The docs can be found at [https://hexdocs.pm/ex_bovespa](https://hexdocs.pm/ex_bovespa).

## Changelog

Visit the application releases on the file [CHANGELOG.md](CHANGELOG.md).