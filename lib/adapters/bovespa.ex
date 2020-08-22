defmodule ExBovespa.Adapters.Bovespa do
  @moduledoc """
  Retrieves data from Bovespa's website on listed companies path
  """

  @base_url "http://bvmf.bmfbovespa.com.br/cias-listadas/Titulos-Negociaveis"
  @list_path "/ResumoTitulosNegociaveis.aspx"
  @details_path "/DetalheTitulosNegociaveis.aspx"

  @doc """
  Gets data on index of listed companies page
  and returns the hole HTML structure
  """
  @spec get_list() :: {:ok, String.t()} | {:error, :invalid_response}
  def get_list do
    [or: "bus", cb: ""]
    |> client()
    |> Tesla.get(@list_path)
    |> handle_response()
  end

  @doc """
  Receives the code for a stock and
  access its details page
  """
  @spec get_item(code :: String.t()) :: {:ok, String.t()} | {:error, :invalid_response}
  def get_item(code) do
    [or: "res", cb: code]
    |> client()
    |> Tesla.get(@details_path)
    |> handle_response()
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response(_), do: {:error, :invalid_response}

  defp client(or: arg_or, cb: cb) do
    query_args = [or: arg_or, tip: "N", cb: cb, idioma: "pt-BR"]

    Tesla.client([
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.Query, query_args}
    ])
  end
end
