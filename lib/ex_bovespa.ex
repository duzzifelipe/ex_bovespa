defmodule ExBovespa do
  @moduledoc """
  ExBovespa helps retrieving stocks data from
  bovespa website by webscraping their HTML data
  """

  alias ExBovespa.Parsers.{StockDetailHtml, StockListHtml}
  alias ExBovespa.Structs.Stock

  require Logger

  @parallel_chunk_size Application.get_env(:ex_bovespa, :parallelism, 100)
  @adapter_module Application.get_env(:ex_bovespa, :adapter_module, ExBovespa.Adapters.Bovespa)

  @doc """
  Returns a list of all stocks from bovespa website.

  While running tests on development environment,
  it took more than 1min 30s to load the entire
  list of currently availble stocks on B3.

  ### Example

      iex> ExBovespa.stock_list()
      [
        %Stock{}
      ]
  """
  @spec stock_list() :: {:ok, list(Stock.t())} | {:error, :invalid_response}
  def stock_list do
    Logger.debug("#{__MODULE__}.stock_list")

    case @adapter_module.get_list() do
      {:ok, html} ->
        {:ok, parse_items(html)}

      error ->
        Logger.error("#{__MODULE__}.stock_list error=#{inspect(error)}")
        error
    end
  end

  defp parse_items(html) do
    html
    |> StockListHtml.parse()
    |> Enum.chunk_every(@parallel_chunk_size)
    |> Enum.map(&get_items/1)
    |> List.flatten()
  end

  defp get_items(stock_list) do
    Logger.debug("#{__MODULE__}.get_items")

    stock_list
    |> Enum.map(&Task.async(fn -> get_item(&1) end))
    |> Enum.map(&Task.await(&1, :infinity))
  end

  defp get_item(%Stock{company_code: code} = stock) do
    Logger.debug("#{__MODULE__}.get_item")

    case @adapter_module.get_item(code) do
      {:ok, html} ->
        StockDetailHtml.parse(html, stock)

      error ->
        Logger.error("#{__MODULE__}.get_item error=#{inspect(error)}")
        stock
    end
  end
end
