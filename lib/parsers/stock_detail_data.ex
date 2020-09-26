defmodule ExBovespa.Parsers.StockDetailData do
  @moduledoc """
  Exposes a function functions to decode
  specific data from StockDetailHtml
  """

  alias ExBovespa.Structs.Stock

  @doc """
  Receives a Stock struct and combines with
  an item's description to determine which type
  of stock title it is
  """
  @spec parse_description(description :: String.t(), stock :: Stock.t()) ::
          :stock | :fii | :bdr | :fidc | :etf | :fund | :index | nil
  def parse_description("DRN" <> _string_tail, _stock), do: :bdr
  def parse_description("ON" <> _string_tail, _stock), do: :stock
  def parse_description("PN" <> _string_tail, _stock), do: :stock
  def parse_description("UNT" <> _string_tail, _stock), do: :stock
  def parse_description("DR3" <> _string_tail, _stock), do: :stock
  def parse_description("FIDC" <> _string_tail, _stock), do: :fidc

  def parse_description(_description, %Stock{} = stock) do
    cond do
      String.contains?(stock.short_name, "FII") ->
        :fii

      String.contains?(stock.name, "ETF") or String.contains?(stock.name, "IT NOW") or
          String.contains?(stock.name, "ISHARES") ->
        :etf

      String.contains?(stock.name, "FDO") ->
        :fund

      String.contains?(stock.name, "ÍNDICE") or String.contains?(stock.name, "INDICE") ->
        :index

      true ->
        nil
    end
  end
end
