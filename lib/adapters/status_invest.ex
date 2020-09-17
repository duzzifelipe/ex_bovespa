defmodule ExBovespa.Adapters.StatusInvest do
  @moduledoc """
  Retrieves "real estate stocks" list from statusinvest
  """

  @behaviour ExBovespa.Adapters.StatusInvestBehaviour

  @base_url "https://statusinvest.com.br"
  @fii_list_path "/fii/fundsnavigation"
  @stock_list_path "/acao/companiesnavigation"
  @price_path "/category/tickerprice"
  @page_size 10_000

  @doc """
  Gets json data from the list of FIIs
  """
  @impl true
  def get_fii_list do
    client()
    |> Tesla.get(@fii_list_path, query: [page: 1, size: @page_size])
    |> handle_response()
  end

  @doc """
  Gets json data from the list of Stocks
  """
  @impl true
  def get_stock_list do
    client()
    |> Tesla.get(@stock_list_path, query: [page: 1, size: @page_size])
    |> handle_response()
  end

  @doc """
  Receives a code for a stock or FII and
  a type (related to range) for filtering the API

  Type:
    -1: 1 day
    0: 5 days
    1: 1 month
    2: 6 months
    3: 1 year
    4: 5 years
  """
  @impl true
  def get_stock_price(code, type) do
    client()
    |> Tesla.get(@price_path, query: [ticker: code, type: type])
    |> handle_response()
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response(_), do: {:error, :invalid_response}

  defp client do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @base_url},
      Tesla.Middleware.JSON
    ])
  end
end
