defmodule ExBovespa.Parsers.BrokerListHtml do
  @moduledoc """
  Parses each table item representing a broker name,
  code and image.

  Also returns the pagination information such as
  total pages and current page.
  """

  alias ExBovespa.Helpers.StringHelper
  alias ExBovespa.Structs.Broker

  @doc """
  Receives the html structure from a page
  from broker lst and returns the list of items
  """
  def parse(html) do
    document = Floki.parse_document!(html)

    items =
      document
      |> Floki.find(".lum-content .lum-content-body .row.corretoras")
      |> Enum.map(&get_row_data/1)

    {current_page, total_pages} =
      document
      |> Floki.find("ul.pagination li")
      |> enumarate_pages()

    %{
      items: items,
      current_page: current_page,
      total_pages: total_pages
    }
  end

  defp get_row_data(row) do
    row
    |> Floki.find("div h6 a")
    |> get_link_data()
  end

  defp get_link_data([{"a", _attrs, [name]}]) do
    name
    |> StringHelper.remove_blank_spaces()
    |> String.split(" - ")
    |> build_broker()
  end

  # sets the last item as the code
  # and rejoins the others
  # since a name can be separated by "-"
  defp build_broker(list) do
    %Broker{
      name: list |> Enum.slice(0..-2) |> Enum.join(" - "),
      code: Enum.at(list, -1)
    }
  end

  defp enumarate_pages(links) do
    Enum.reduce(links, {nil, nil}, fn
      {"li", [{"class", "current"}], [{"a", _attrs, [page_num]}]}, {_, total} ->
        {String.to_integer(page_num), total}

      {"li", _attrs_1, [{"a", _attrs_2, [page_num]}]}, {current, total} ->
        num = Integer.parse(page_num)

        if num != :error and total < num do
          {current, elem(num, 0)}
        else
          {current, total}
        end
    end)
  end
end
