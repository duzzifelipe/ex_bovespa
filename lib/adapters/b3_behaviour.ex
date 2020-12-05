defmodule ExBovespa.Adapters.B3Behaviour do
  @moduledoc """
  Defines the functions implemented by B3 adapter
  """

  @callback get_company_list ::
              {:ok, list(map())} | {:error, :invalid_response}
end
