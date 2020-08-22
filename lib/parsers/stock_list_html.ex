defmodule ExBovespa.Parsers.StockListHtml do
  @moduledoc """
  Module that interprets HTML syntax into
  a list of elements on a table
  """

  alias ExBovespa.Structs.Stock

  @code_from_link_regex ~r/.*&cb=(.*)&tip=.*/
  @remove_blanks_regex ~r/\s+/

  @doc """
  Receives an HTML tree and finds the table lines
  corresponding to each listed company row
  then retrieves the company code, its name
  and its short name
  """
  @spec parse(String.t()) :: list(Stock.t())
  def parse(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("table#ctl00_contentPlaceHolderConteudo_grdEmpresas_ctl01 tbody tr")
    |> Stream.map(&parse_row/1)
    |> Stream.filter(&(not is_nil(&1)))
    |> Enum.to_list()
  end

  defp parse_row({"tr", _attrs, [left_item, right_item]}) do
    with {:ok, {link, name}} <- parse_item(left_item),
         {:ok, {_link, short_name}} <- parse_item(right_item),
         {:ok, code} <- code_from_link(link) do
      %Stock{
        company_code: code,
        name: remove_blank_spaces(name),
        short_name: remove_blank_spaces(short_name)
      }
    end
  end

  defp parse_row(_), do: nil

  defp parse_item({"td", _attrs, [{"a", [{"href", link}], [name]}]}) do
    {:ok, {link, name}}
  end

  defp parse_item(_), do: nil

  defp code_from_link(link) do
    case Regex.run(@code_from_link_regex, link) do
      [_, code] ->
        {:ok, code}

      _ ->
        nil
    end
  end

  defp remove_blank_spaces(string) do
    @remove_blanks_regex
    |> Regex.replace(string, " ")
    |> String.trim()
  end
end
