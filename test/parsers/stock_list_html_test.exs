defmodule ExBovespa.Parsers.StockListHtmlTest do
  use ExUnit.Case

  alias ExBovespa.Parsers.StockListHtml

  describe "parse/1" do
    test "should return the list and correctly build the struct" do
      syntax = """
      <html>
        <body>
          <table id="ctl00_contentPlaceHolderConteudo_grdEmpresas_ctl01">
            <tbody>
              <tr>
                <td>
                  <a href="http://bvmf.bmfbovespa.com.br/cias-listadas/Titulos-Negociaveis/DetalheTitulosNegociaveis.aspx?or=res&amp;cb=MMMC&amp;tip=N&amp;idioma=pt-BR">
                  3M
                  COMPANY
                  </a>
                </td>
                <td>
                  <a href="http://bvmf.bmfbovespa.com.br/cias-listadas/Titulos-Negociaveis/DetalheTitulosNegociaveis.aspx?or=res&amp;cb=MMMC&amp;tip=N&amp;idioma=pt-BR">
                  3M
                  </a>
                </td>
              </tr>
            </tbody>
          </table>
        </body>
      </html>
      """

      parsed = StockListHtml.parse(syntax)
      %struct_name{} = first = Enum.at(parsed, 0)

      assert struct_name == ExBovespa.Structs.Stock

      assert Map.keys(first) == [:__struct__, :company_code, :detail_list, :name, :short_name]
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
