defmodule ExBovespa.Structs.Stock do
  @moduledoc """
  Holds the data related to a stock.

  company_code: a primary code for the stock, helpful for accessing the details page
  name: full stock name
  short_name: known name for this company
  """

  @type t() :: %__MODULE__{
          company_code: String.t(),
          name: String.t(),
          short_name: String.t()
        }

  defstruct [:company_code, :name, :short_name]
end
