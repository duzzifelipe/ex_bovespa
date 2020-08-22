defmodule ExBovespa.Structs.Stock do
  @moduledoc """
  Holds the data related to a stock's company.

  company_code: a primary code for the stock, helpful for accessing the details page
  name: full stock name
  short_name: known name for this company
  """

  alias ExBovespa.Structs.StockDetail

  @type t() :: %__MODULE__{
          company_code: String.t(),
          name: String.t(),
          short_name: String.t(),
          detail_list: list(StockDetail.t()) | nil
        }

  defstruct [:company_code, :name, :short_name, :detail_list]
end
