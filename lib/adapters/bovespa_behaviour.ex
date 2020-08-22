defmodule ExBovespa.Adapters.BovespaBehaviour do
  @moduledoc """
  Defines the functions implemented by Bovespa adapter
  """

  @callback get_list() :: {:ok, String.t()} | {:error, :invalid_response}
  @callback get_item(code :: String.t()) :: {:ok, String.t()} | {:error, :invalid_response}
end
