defmodule ExBovespa.Structs.StatusInvestStock do
  @moduledoc """
  Holds the data related to an item on Stocks
  or FIIs lists - identified by the "type"
  """

  @type t() :: %__MODULE__{
          code: String.t(),
          company_name: String.t(),
          type: :stock | :fii
        }

  defstruct [:code, :company_name, :type]
end
