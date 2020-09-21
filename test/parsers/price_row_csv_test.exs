defmodule ExBovespa.Parsers.PriceRowCsvTest do
  use ExUnit.Case
  alias ExBovespa.Parsers.PriceRowCsv

  setup do
    template = """
    00COTAHIST.2020BOVESPA 20200918
    012020091802A1AP34      010ADVANCE AUTODRN ED       R$  000000002059800000000205980000000020598000000002059800000000205980000000000000000000002216000001000000000000003710000000000076418580000000000000009999123100000010000000000000BRA1APBDR001103
    012020091802A1BM34      010ABIOMED INC DRN          R$  000000003541100000000354110000000035411000000003541100000000354110000000000000000000000000000001000000000000000070000000000002478770000000000000009999123100000010000000000000BRA1BMBDR006100
    99COTAHIST.2020BOVESPA 2020091800000006212
    """

    file_name = "/tmp/#{Base.url_encode64(:crypto.strong_rand_bytes(16))}.txt"
    File.write!(file_name, template)

    [file_name: file_name]
  end

  describe "parse/1" do
    test "should parse headers", %{file_name: file_name} do
      assert [header: header, items: _] = PriceRowCsv.parse(file_name)

      assert header == %{
               file_name: "COTAHIST.2020",
               source: "BOVESPA",
               created_at: ~D[2020-09-18]
             }
    end

    test "should parse lines", %{file_name: file_name} do
      assert [header: _, items: items] = PriceRowCsv.parse(file_name)

      assert items == [
               %{
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
               %{
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
    end
  end
end
