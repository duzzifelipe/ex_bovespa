defmodule ExBovespa.Structs.StockDetail do
  @moduledoc """
  Holds data for a stock details and is
  a child of "Stock" struct.

  This is isolated from main struct since
  a company can have multiple stock codes.
  """

  @type t() :: %__MODULE__{
          code: String.t(),
          isin_code: String.t()
        }

  defstruct [:code, :isin_code]
end
