defmodule ExBovespa.Adapters.B3Behaviour do
  @moduledoc """
  Defines the functions implemented by B3 adapter
  """

  @callback get_company_list_by_page(page :: pos_integer()) ::
              {:ok, String.t()} | {:error, :invalid_response}
end