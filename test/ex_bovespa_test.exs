defmodule ExBovespaTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  import Mox

  alias ExBovespa.Structs.{Broker, Stock, StockDetail}

  defp list_content_mock do
    """
    <html>
      <body>
        <table id="ctl00_contentPlaceHolderConteudo_grdEmpresas_ctl01">
          <tbody>
            <tr>
              <td>
                <a href="http://bvmf.bmfbovespa.com.br/cias-listadas/Titulos-Negociaveis/DetalheTitulosNegociaveis.aspx?or=res&amp;cb=IBOV&amp;tip=N&amp;idioma=pt-BR">
                INDICE BOVESPA
                </a>
              </td>
              <td>
                <a href="http://bvmf.bmfbovespa.com.br/cias-listadas/Titulos-Negociaveis/DetalheTitulosNegociaveis.aspx?or=res&amp;cb=IBOV&amp;tip=N&amp;idioma=pt-BR">
                IBOVESPA
                </a>
              </td>
            </tr>
          </tbody>
        </table>
      </body>
    </html>
    """
  end

  describe "stock_list/0" do
    test "returns empty list from service" do
      expect(ExBovespa.Adapters.BovespaMock, :get_list, fn ->
        {:ok, "<html></html>"}
      end)

      assert {:ok, []} = ExBovespa.stock_list()
    end

    test "returns list items" do
      expect(ExBovespa.Adapters.BovespaMock, :get_list, fn ->
        {:ok, list_content_mock()}
      end)

      expect(ExBovespa.Adapters.BovespaMock, :get_item, fn "IBOV" ->
        {:ok,
         """
         <html>
           <body>
             <table id="ctl00_contentPlaceHolderConteudo_ctl00_grdDados_ctl01">
               <tbody>
                 <tr><td>BRIBOVINDM18</td><td></td><td>IBOV11</td></tr>
               </tbody>
             </table>
           </body>
         </html>
         """}
      end)

      assert {:ok,
              [
                %Stock{
                  company_code: "IBOV",
                  name: "INDICE BOVESPA",
                  short_name: "IBOVESPA",
                  detail_list: [
                    %StockDetail{
                      code: "IBOV11",
                      isin_code: "BRIBOVINDM18"
                    }
                  ]
                }
              ]} == ExBovespa.stock_list()
    end

    test "returns empty item data" do
      expect(ExBovespa.Adapters.BovespaMock, :get_list, fn ->
        {:ok, list_content_mock()}
      end)

      expect(ExBovespa.Adapters.BovespaMock, :get_item, fn "IBOV" ->
        {:ok, ""}
      end)

      assert {:ok,
              [
                %ExBovespa.Structs.Stock{
                  company_code: "IBOV",
                  detail_list: nil,
                  name: "INDICE BOVESPA",
                  short_name: "IBOVESPA"
                }
              ]} = ExBovespa.stock_list()
    end

    test "returns http error from list service" do
      expect(ExBovespa.Adapters.BovespaMock, :get_list, fn ->
        {:error, :invalid_response}
      end)

      assert capture_log(fn ->
               assert {:error, :invalid_response} = ExBovespa.stock_list()
             end) =~ "[error] Elixir.ExBovespa.stock_list error={:error, :invalid_response}"
    end

    test "raises error from get_item service" do
      expect(ExBovespa.Adapters.BovespaMock, :get_list, fn ->
        {:ok, list_content_mock()}
      end)

      expect(ExBovespa.Adapters.BovespaMock, :get_item, fn "IBOV" ->
        {:error, :invalid_response}
      end)

      assert capture_log(fn ->
               assert {:ok,
                       [
                         %ExBovespa.Structs.Stock{
                           company_code: "IBOV",
                           detail_list: nil,
                           name: "INDICE BOVESPA",
                           short_name: "IBOVESPA"
                         }
                       ]} = ExBovespa.stock_list()
             end) =~ "[error] Elixir.ExBovespa.get_item error={:error, :invalid_response}"
    end
  end

  describe "broker_list/0" do
    @base_html """
      <html>
        <body>
          <div class="lum-content">
            <div class="lum-content-body">
              <div class="large-12 columns">
                <div class="row">
                  <div class="large-8 columns">
                    <div class="row corretoras">
                      <div class="large-9 columns">
                        <h6 class="subheader">
                          <a href="">COMPANY FROM PAGE - ##page##</a></h6>
                      </div>
                    </div>
                    <div class="row">
                      <div class="large-5 large-centered columns text-center">
                        <ul class="pagination">
                          <li class="arrow unavailable"><a href="">«</a></li>
                          <li class="##is-page-1##"><a href="">1</a>
                          </li>
                          <li class="##is-page-2##"><a href="">2</a>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </body>
      </html>
    """

    test "returns empty list from service" do
      expect(ExBovespa.Adapters.B3Mock, :get_company_list_by_page, fn _page_num ->
        {:ok, "<html></html>"}
      end)

      assert {:error, :invalid_response} = ExBovespa.broker_list()
    end

    test "returns list items should call 2 pages" do
      expect(ExBovespa.Adapters.B3Mock, :get_company_list_by_page, 2, fn page ->
        html = String.replace(@base_html, "##page##", to_string(page))

        case page do
          1 ->
            {:ok, String.replace(html, "##is-page-1##", "current")}

          2 ->
            {:ok, String.replace(html, "##is-page-2##", "current")}
        end
      end)

      assert {:ok,
              [
                %Broker{code: "1", name: "COMPANY FROM PAGE"},
                %Broker{code: "2", name: "COMPANY FROM PAGE"}
              ]} = ExBovespa.broker_list()
    end

    test "returns http error from list service on any page" do
      expect(ExBovespa.Adapters.B3Mock, :get_company_list_by_page, 2, fn page ->
        html = String.replace(@base_html, "##page##", to_string(page))

        case page do
          1 ->
            {:ok, String.replace(html, "##is-page-1##", "current")}

          2 ->
            {:ok, "<html></html>"}
        end
      end)

      assert {:error, :invalid_response} = ExBovespa.broker_list()
    end
  end
end
