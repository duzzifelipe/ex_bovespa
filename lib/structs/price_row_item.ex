defmodule ExBovespa.Structs.PriceRowItem do
  @moduledoc """
  Holds data for each occurrence for stock
  pricing on historical quotes file
  """

  @type t() :: %__MODULE__{
          date: Date.t(),
          bdi: String.t(),
          code: String.t(),
          isin_code: String.t(),
          market_type: String.t(),
          company_name: String.t(),
          specification: String.t(),
          market_term: String.t(),
          currency_symbol: String.t(),
          opening_price: Decimal.t(),
          closing_price: Decimal.t(),
          lowest_price: Decimal.t(),
          highest_price: Decimal.t(),
          average_price: Decimal.t(),
          best_purchase_price: Decimal.t(),
          best_sell_price: Decimal.t(),
          total_trades: non_neg_integer(),
          titles_traded: non_neg_integer(),
          volume_traded: Decimal.t(),
          strike_price: Decimal.t(),
          strike_price_correction: String.t(),
          maturity_date: Date.t(),
          quotation_factor: non_neg_integer(),
          strike_price_points: non_neg_integer(),
          distribution_number: String.t()
        }

  defstruct [
    :date,
    :bdi,
    :code,
    :isin_code,
    :market_type,
    :company_name,
    :specification,
    :market_term,
    :currency_symbol,
    :opening_price,
    :closing_price,
    :lowest_price,
    :highest_price,
    :average_price,
    :best_purchase_price,
    :best_sell_price,
    :total_trades,
    :titles_traded,
    :volume_traded,
    :strike_price,
    :strike_price_correction,
    :maturity_date,
    :quotation_factor,
    :strike_price_points,
    :distribution_number
  ]
end
