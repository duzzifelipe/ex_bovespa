defmodule ExBovespa.Parsers.StockDetailHtmlTest do
  use ExUnit.Case

  alias ExBovespa.Parsers.StockDetailHtml
  alias ExBovespa.Structs.{Stock, StockDetail}

  describe "parse/2" do
    test "should return main details from page" do
      syntax = """
      <html>
        <body>
          <table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01">
            <tbody>
              <tr><td>BRIBOVINDM18</td><td></td><td>IBOV11</td></tr>
            </tbody>
          </table>
        </body>
      </html>
      """

      assert %Stock{
               detail_list: [
                 %StockDetail{
                   code: "IBOV11",
                   isin_code: "BRIBOVINDM18"
                 }
               ]
             } = StockDetailHtml.parse(syntax, %Stock{})
    end

    test "should return details for multiple stocks" do
      syntax = """
      <html>
        <body>
          <table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01">
            <tbody>
              <tr><td>BRIBOVINDM18</td><td></td><td>IBOV11</td></tr>
              <tr><td>BRIBOVINDM18</td><td></td><td>IBOV11</td></tr>
            </tbody>
          </table>
        </body>
      </html>
      """

      assert %Stock{
               detail_list: [
                 %StockDetail{
                   code: "IBOV11",
                   isin_code: "BRIBOVINDM18"
                 },
                 %StockDetail{
                   code: "IBOV11",
                   isin_code: "BRIBOVINDM18"
                 }
               ]
             } = StockDetailHtml.parse(syntax, %Stock{})
    end

    test "should return original struct if html doesn't match" do
      invalid_trees = [
        "",
        "<html></html>",
        "<html><body></body></html>",
        "<html><body><table></table></body></html>",
        "<html><body><table></table></body></html>",
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01"></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01"><tbody></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01"><tbody><tr></tr></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01"><tbody><tr><td></td></tr></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01"><tbody><tr><td></td><td></td></tr></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01"><tbody><tr><td></td><td></td><td></td></tr></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01"><tbody><tr><td>value</td><td></td><td></td></tr></tbody></table></body></html>),
        ~S(<html><body><table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01"><tbody><tr><td></td><td></td><td>value</td></tr></tbody></table></body></html>)
      ]

      for html <- invalid_trees do
        assert %Stock{detail_list: nil} = StockDetailHtml.parse(html, %Stock{})
      end
    end

    test "parse table with only two columns" do
      syntax = """
      <html>
        <body>
          <table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01">
            <tbody>
              <tr><td>BRIBOVINDM18</td><td>CT2</td></tr>
            </tbody>
          </table>
        </body>
      </html>
      """

      assert %Stock{
               detail_list: [
                 %StockDetail{
                   code: nil,
                   isin_code: "BRIBOVINDM18"
                 }
               ]
             } = StockDetailHtml.parse(syntax, %Stock{})
    end
  end
end
