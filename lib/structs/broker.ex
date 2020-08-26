defmodule ExBovespa.Structs.Broker do
  @moduledoc """
  Holds the data related to a broker
  """

  @type t() :: %__MODULE__{
          name: String.t(),
          code: String.t()
        }

  defstruct [:name, :code]
end
