defmodule ExBovespa do
  @moduledoc """
  ExBovespa helps retrieving stocks data from
  bovespa website by webscraping their HTML data
  """

  alias ExBovespa.Parsers.{BrokerListHtml, StockDetailHtml, StockListHtml}
  alias ExBovespa.Structs.{Broker, Stock}

  require Logger

  @parallel_chunk_size Application.get_env(:ex_bovespa, :parallelism, 100)
  @stock_adapter_module Application.get_env(
                          :ex_bovespa,
                          :stock_adapter_module,
                          ExBovespa.Adapters.Bovespa
                        )
  @broker_adapter_module Application.get_env(
                           :ex_bovespa,
                           :broker_adapter_module,
                           ExBovespa.Adapters.B3
                         )

  @doc """
  Returns a list of all stocks from bovespa website.

  While running tests on development environment,
  it took more than 1min 30s to load the entire
  list of currently availble stocks on B3.

  ### Example

      iex> ExBovespa.stock_list()
      {:ok, [
        %Stock{}
      ]}
  """
  @spec stock_list() :: {:ok, list(Stock.t())} | {:error, :invalid_response}
  def stock_list do
    Logger.debug("#{__MODULE__}.stock_list")

    case @stock_adapter_module.get_list() do
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

    case @stock_adapter_module.get_item(code) do
      {:ok, html} ->
        StockDetailHtml.parse(html, stock)

      error ->
        Logger.error("#{__MODULE__}.get_item error=#{inspect(error)}")
        stock
    end
  end

  @doc """
  Returns a list of all brokers from bovespa website.

  This resource on bovespa's website uses pagination,
  so each html request and parser will return a list
  of items and paging information, that will be
  used to loop until all pages are visited.

  ### Example

      iex> ExBovespa.broker_list()
      {:ok, [
        %Broker{}
      ]}
  """
  @spec broker_list() :: {:ok, list(Broker.t())} | {:error, :invalid_response}
  def broker_list do
    Logger.debug("#{__MODULE__}.broker_list")

    do_get_broker_list([], 0, nil)
  end

  # when the two paginator items (current_page, total_pages)
  # are the same (max_page, max_page), will return the acc
  defp do_get_broker_list(acc, max_page, max_page), do: {:ok, acc}

  defp do_get_broker_list(acc, current_page, total_pages) do
    Logger.debug(
      "#{__MODULE__}.do_get_broker_list current_page=#{current_page} total_pages=#{total_pages}"
    )

    case @broker_adapter_module.get_company_list_by_page(current_page + 1) do
      {:ok, html} ->
        %{
          items: items,
          current_page: new_current_page,
          total_pages: new_total_pages
        } = BrokerListHtml.parse(html)

        do_get_broker_list(acc ++ items, new_current_page, new_total_pages)

      error ->
        Logger.error("#{__MODULE__}.do_get_broker_list error=#{inspect(error)}")
        error
    end
  end
end
