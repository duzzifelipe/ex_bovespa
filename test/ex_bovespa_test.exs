defmodule ExBovespaTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  import Mox

  alias ExBovespa.Structs.{Broker, PriceRowHeader, PriceRowItem, Stock, StockDetail}

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

  defp price_file_mock do
    file_name = "/tmp/#{Base.encode16(:crypto.strong_rand_bytes(16), padding: false)}"
    file_name_char = String.to_charlist(file_name)

    file_content = """
    00COTAHIST.2020BOVESPA 20200918
    012020091802A1AP34      010ADVANCE AUTODRN ED       R$  000000002059800000000205980000000020598000000002059800000000205980000000000000000000002216000001000000000000003710000000000076418580000000000000009999123100000010000000000000BRA1APBDR001103
    012020091802A1BM34      010ABIOMED INC DRN          R$  000000003541100000000354110000000035411000000003541100000000354110000000000000000000000000000001000000000000000070000000000002478770000000000000009999123100000010000000000000BRA1BMBDR006100
    99COTAHIST.2020BOVESPA 2020091800000006212
    """

    :ok = File.write!(file_name <> ".txt", file_content)

    {:ok, zip_dir} =
      :zip.create(file_name_char ++ '.zip', [file_name_char ++ '.txt'], cwd: file_name_char)

    File.read!(zip_dir)
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
                 <tr><td>BRIBOVINDM18</td><td>ON</td><td>IBOV11</td></tr>
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
                      isin_code: "BRIBOVINDM18",
                      type: :stock
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

  describe "historical_price/1" do
    @sample_result [
      header: %PriceRowHeader{
        file_name: "COTAHIST.2020",
        source: "BOVESPA",
        created_at: ~D[2020-09-18]
      },
      items: [
        %PriceRowItem{
          date: ~D[2020-09-18],
          bdi: "02",
          code: "A1AP34",
          market_type: "010",
          company_name: "ADVANCE AUTO",
          specification: "DRN ED",
          currency_symbol: "R$",
          market_term: "",
          average_price: Decimal.from_float(205.98),
          best_purchase_price: elem(Decimal.parse("0.00"), 1),
          best_sell_price: elem(Decimal.parse("221.60"), 1),
          closing_price: Decimal.from_float(205.98),
          distribution_number: "103",
          highest_price: Decimal.from_float(205.98),
          isin_code: "BRA1APBDR001",
          lowest_price: Decimal.from_float(205.98),
          maturity_date: ~D[9999-12-31],
          opening_price: Decimal.from_float(205.98),
          quotation_factor: 1,
          strike_price: elem(Decimal.parse("0.00"), 1),
          strike_price_correction: "0",
          strike_price_points: 0,
          titles_traded: 3710,
          total_trades: 1,
          volume_traded: elem(Decimal.parse("764185.80"), 1)
        },
        %PriceRowItem{
          date: ~D[2020-09-18],
          bdi: "02",
          code: "A1BM34",
          market_type: "010",
          company_name: "ABIOMED INC",
          specification: "DRN",
          currency_symbol: "R$",
          market_term: "",
          average_price: Decimal.from_float(354.11),
          best_purchase_price: elem(Decimal.parse("0.00"), 1),
          best_sell_price: elem(Decimal.parse("0.00"), 1),
          closing_price: Decimal.from_float(354.11),
          distribution_number: "100",
          highest_price: Decimal.from_float(354.11),
          isin_code: "BRA1BMBDR006",
          lowest_price: Decimal.from_float(354.11),
          maturity_date: ~D[9999-12-31],
          opening_price: Decimal.from_float(354.11),
          quotation_factor: 1,
          strike_price: elem(Decimal.parse("0.00"), 1),
          strike_price_correction: "0",
          strike_price_points: 0,
          titles_traded: 70,
          total_trades: 1,
          volume_traded: elem(Decimal.parse("24787.70"), 1)
        }
      ]
    ]

    test "returns list items" do
      year = to_string(Enum.random(1970..2050))

      expect(ExBovespa.Adapters.BovespaMock, :get_historical_file, fn ^year ->
        {:ok, price_file_mock()}
      end)

      assert {:ok, @sample_result} == ExBovespa.historical_price(year)
    end

    test "returns http error from list service" do
      year = to_string(Enum.random(1970..2050))

      expect(ExBovespa.Adapters.BovespaMock, :get_historical_file, fn ^year ->
        {:error, :invalid_response}
      end)

      assert {:error, :invalid_response} = ExBovespa.historical_price(year)
    end
  end

  describe "historical_price/2" do
    test "returns list items" do
      year = to_string(Enum.random(1970..2050))
      month = to_string(Enum.random(1..12))

      expect(ExBovespa.Adapters.BovespaMock, :get_historical_file, fn ^year, ^month ->
        {:ok, price_file_mock()}
      end)

      assert {:ok, @sample_result} == ExBovespa.historical_price(year, month)
    end

    test "returns http error from list service" do
      year = to_string(Enum.random(1970..2050))
      month = to_string(Enum.random(1..12))

      expect(ExBovespa.Adapters.BovespaMock, :get_historical_file, fn ^year, ^month ->
        {:error, :invalid_response}
      end)

      assert {:error, :invalid_response} = ExBovespa.historical_price(year, month)
    end
  end

  describe "historical_price/3" do
    test "returns list items" do
      year = to_string(Enum.random(1970..2050))
      month = to_string(Enum.random(1..12))
      day = to_string(Enum.random(1..31))

      expect(ExBovespa.Adapters.BovespaMock, :get_historical_file, fn ^year, ^month, ^day ->
        {:ok, price_file_mock()}
      end)

      assert {:ok, @sample_result} == ExBovespa.historical_price(year, month, day)
    end

    test "returns http error from list service" do
      year = to_string(Enum.random(1970..2050))
      month = to_string(Enum.random(1..12))
      day = to_string(Enum.random(1..31))

      expect(ExBovespa.Adapters.BovespaMock, :get_historical_file, fn ^year, ^month, ^day ->
        {:error, :invalid_response}
      end)

      assert {:error, :invalid_response} = ExBovespa.historical_price(year, month, day)
    end
  end
end
