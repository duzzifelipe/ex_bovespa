defmodule ExBovespa.Parsers.StockDetailHtml do
  @moduledoc """
  Module that interprets HTML syntax into
  a struct of important data
  """

  alias ExBovespa.Structs.{Stock, StockDetail}

  @doc """
  Receives a HTML tree and finds the table lines
  corresponding to each stock code for current company,
  then updates the given stock struct with StockDetail list
  """
  @spec parse(stock :: Stock.t(), html :: String.t()) :: Stock.t()
  def parse(stock, html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("table#ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01 tbody tr")
    |> Stream.map(&parse_row/1)
    |> Stream.filter(&(not is_nil(&1)))
    |> Enum.to_list()
    |> merge_results_into_struct(stock)
  end

  defp parse_row({"tr", _attrs, [first_item, _second_item, third_item]}) do
    with {:ok, isin_code} <- parse_item(first_item),
         {:ok, code} <- parse_item(third_item) do
      %StockDetail{
        isin_code: String.trim(isin_code),
        code: String.trim(code)
      }
    end
  end

  defp parse_row(_), do: nil

  defp parse_item({"td", _attrs, [text]}) do
    {:ok, text}
  end

  defp parse_item(_), do: nil

  defp merge_results_into_struct([], stock), do: merge_results_into_struct(nil, stock)

  defp merge_results_into_struct(list, %Stock{} = stock) do
    %Stock{stock | detail_list: list}
  end
end
