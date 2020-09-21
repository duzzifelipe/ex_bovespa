defmodule ExBovespa.Parsers.PriceRowCsv do
  @moduledoc """
  From a text file name (as string), breaks
  each line and decode each column by their
  fixed string size based on the layout
  provided by B3 (at section "What is the file layout?"):
  http://www.b3.com.br/en_us/market-data-and-indices/data-services/market-data/historical-data/equities/historical-quote-data/
  """

  alias ExBovespa.Structs.{PriceRowHeader, PriceRowItem}

  @doc """
  Receives a file name and opens it as a stream
  to apply data decoders
  """
  @spec parse(file_name :: String.t() | charlist()) :: [
          header: PriceRowHeader.t(),
          items: list(PriceRowItem.t())
        ]
  def parse(file_name) do
    [header | items] =
      file_name
      |> File.stream!()
      |> Stream.map(&decode_line/1)
      |> Stream.drop(-1)
      |> Enum.to_list()

    [
      header: header,
      items: items
    ]
  end

  defp decode_line(
         <<tipreg::binary-size(2), date::binary-size(8), codbdi::binary-size(2),
           codneg::binary-size(12), tpmerc::binary-size(3), nomres::binary-size(12),
           especi::binary-size(10), prazot::binary-size(3), modref::binary-size(4),
           preabe::binary-size(13), premax::binary-size(13), premin::binary-size(13),
           premed::binary-size(13), preult::binary-size(13), preofc::binary-size(13),
           preofv::binary-size(13), totneg::binary-size(5), quatot::binary-size(18),
           voltot::binary-size(18), preexe::binary-size(13), indopc::binary-size(1),
           datven::binary-size(8), fatcot::binary-size(7), ptoexe::binary-size(13),
           codisi::binary-size(12), dismes::binary-size(3), _::bitstring>>
       )
       when tipreg == "01" do
    %PriceRowItem{
      date: parse_date(date),
      bdi: codbdi,
      code: String.trim(codneg),
      isin_code: codisi,
      market_type: tpmerc,
      company_name: String.trim(nomres),
      specification: String.trim(especi),
      market_term: String.trim(prazot),
      currency_symbol: String.trim(modref),
      opening_price: parse_float(preabe),
      closing_price: parse_float(preult),
      lowest_price: parse_float(premin),
      highest_price: parse_float(premax),
      average_price: parse_float(premed),
      best_purchase_price: parse_float(preofc),
      best_sell_price: parse_float(preofv),
      total_trades: String.to_integer(totneg),
      titles_traded: String.to_integer(quatot),
      volume_traded: parse_float(voltot),
      strike_price: parse_float(preexe),
      strike_price_correction: indopc,
      maturity_date: parse_date(datven),
      quotation_factor: String.to_integer(fatcot),
      strike_price_points: String.to_integer(ptoexe),
      distribution_number: dismes
    }
  end

  defp decode_line(
         <<type::binary-size(2), file_name::binary-size(13), source::binary-size(8),
           created_at::binary-size(8), _::bitstring>>
       )
       when type == "00" do
    %PriceRowHeader{
      file_name: file_name,
      source: String.trim(source),
      created_at: parse_date(created_at)
    }
  end

  defp decode_line(<<type::binary-size(2), _::bitstring>>) when type == "99", do: nil

  defp parse_date(string) do
    string
    |> Timex.parse!("{YYYY}{M}{D}")
    |> NaiveDateTime.to_date()
  end

  defp parse_float(string) do
    integer = String.to_integer(string)
    Decimal.new(1, integer, -2)
  end
end
