defmodule ExBovespa.Behaviour do
  @moduledoc false

  alias ExBovespa.Structs.{Broker, PriceRowHeader, PriceRowItem, Stock}

  @type success_price_return :: {:ok, [header: PriceRowHeader.t(), items: list(PriceRowItem.t())]}

  @callback stock_list() :: {:ok, list(Stock.t())} | {:error, :invalid_response}

  @callback broker_list() :: {:ok, list(Broker.t())} | {:error, :invalid_response}

  @callback historical_price(year :: String.t()) ::
              success_price_return() | {:error, :invalid_response}

  @callback historical_price(year :: String.t(), month :: String.t()) ::
              success_price_return() | {:error, :invalid_response}

  @callback historical_price(year :: String.t(), month :: String.t(), day :: String.t()) ::
              success_price_return() | {:error, :invalid_response}
end
