defmodule ExBovespa.Adapters.StatusInvestBehaviour do
  @moduledoc """
  Defines the functions implemented by Status Invest adapter
  """

  @callback get_fii_list() :: {:ok, map()} | {:error, :invalid_response}

  @callback get_stock_list() :: {:ok, map()} | {:error, :invalid_response}

  @callback get_stock_price(code :: String.t(), type :: String.t()) ::
              {:ok, map()} | {:error, :invalid_response} | {:error, :invalid_parameters}
end
