defmodule ExBovespa.Structs.PriceRowHeader do
  @moduledoc """
  Shows general information from decoded
  pricing file
  """

  @type t() :: %__MODULE__{
          file_name: String.t(),
          source: String.t(),
          created_at: Date.t()
        }

  defstruct [:file_name, :source, :created_at]
end
