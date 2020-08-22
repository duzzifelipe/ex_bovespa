defmodule ExBovespa.Parsers.StockListHtmlTest do
  use ExUnit.Case

  alias ExBovespa.Parsers.StockListHtml

  @syntax File.read!("test/support/fixtures/stock_list_html_page.html")

  describe "parse/1" do
    test "should return full list from page" do
      parsed = StockListHtml.parse(@syntax)

      assert Enum.count(parsed) == 1257
    end

    test "should build correctly the struct" do
      parsed = StockListHtml.parse(@syntax)
      %struct_name{} = first = Enum.at(parsed, 0)

      assert struct_name == ExBovespa.Structs.Stock

      assert Map.keys(first) == [:__struct__, :company_code, :name, :short_name]
      assert first.company_code == "MMMC"
      assert first.name == "3M COMPANY"
      assert first.short_name == "3M"
    end

    test "should return empty list if html doesn't match" do
      invalid_trees = [
        "",
        "<html></html>",
        "<html><body></body></html>",
        "<html><body><table></table></body></html>",
        "<html><body><table></table></body></html>",
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_grdEmpresas_ctl01"></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_grdEmpresas_ctl01"><tbody></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_grdEmpresas_ctl01"><tbody><tr></tr></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_grdEmpresas_ctl01"><tbody><tr><td></td></tr></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_grdEmpresas_ctl01"><tbody><tr><td></td><td></td></tr></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_grdEmpresas_ctl01"><tbody><tr><td><a></a></td><td><a></a></td></tr></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_grdEmpresas_ctl01"><tbody><tr><td><a href="invalid-link">a</a></td><td><a href="">a</a></td></tr></tbody></table></body></html>)
      ]

      for html <- invalid_trees do
        assert [] = StockListHtml.parse(html)
      end
    end
  end
end
