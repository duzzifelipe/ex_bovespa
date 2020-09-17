defmodule ExBovespa.Structs.StatusInvestPrice do
  @moduledoc """
  Holds the data related to an specific
  stop price list item
  """

  @type t() :: %__MODULE__{
          date: NaiveDateTime.t() | Date.t(),
          price: Decimal.t()
        }

  defstruct [:date, :price]
end
