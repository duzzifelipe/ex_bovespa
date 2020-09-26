defmodule ExBovespa.Parsers.StockDetailHtml do
  @moduledoc """
  Module that interprets HTML syntax into
  a struct of important data
  """

  alias ExBovespa.Helpers.StringHelper
  alias ExBovespa.Parsers.StockDetailData
  alias ExBovespa.Structs.{Stock, StockDetail}

  @doc """
  Receives a HTML tree and finds the table lines
  corresponding to each stock code for current company,
  then updates the given stock struct with StockDetail list
  """
  @spec parse(html :: String.t(), stock :: Stock.t()) :: Stock.t()
  def parse(html, stock) do
    html
    |> Floki.parse_document!()
    |> Floki.find("table#ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01 tbody tr")
    |> Stream.map(&parse_row(&1, stock))
    |> Stream.filter(&(not is_nil(&1)))
    |> Enum.to_list()
    |> merge_results_into_struct(stock)
  end

  # a row with only isin code, but without code
  defp parse_row({"tr", _attrs, [first_item, _second_item]}, _stock) do
    with {:ok, isin_code} <- parse_item(first_item) do
      %StockDetail{
        isin_code: String.trim(isin_code),
        code: nil,
        type: nil
      }
    end
  end

  # a most common row, that includes isin, specification and code
  # and could have more data to the right (ignored as tail)
  defp parse_row({"tr", _attrs, [first_item, second_item, third_item | _tail]}, stock) do
    with {:ok, isin_code} <- parse_item(first_item),
         {:ok, description} <- parse_item(second_item),
         {:ok, code} <- parse_item(third_item) do
      type =
        description
        |> StringHelper.remove_blank_spaces()
        |> StockDetailData.parse_description(stock)

      %StockDetail{
        isin_code: String.trim(isin_code),
        code: String.trim(code),
        type: type
      }
    end
  end

  defp parse_row(_, _), do: nil

  defp parse_item({"td", _attrs, [text]}) do
    {:ok, text}
  end

  defp parse_item(_), do: nil

  defp merge_results_into_struct([], stock), do: merge_results_into_struct(nil, stock)

  defp merge_results_into_struct(list, %Stock{} = stock) do
    %Stock{stock | detail_list: list}
  end
end
