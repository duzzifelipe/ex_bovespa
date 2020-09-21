defmodule ExBovespa.Adapters.Bovespa do
  @moduledoc """
  Retrieves data from Bovespa's website on listed companies path
  """

  @behaviour ExBovespa.Adapters.BovespaBehaviour

  @base_url "http://bvmf.bmfbovespa.com.br"
  @list_path "/cias-listadas/Titulos-Negociaveis/ResumoTitulosNegociaveis.aspx"
  @details_path "/cias-listadas/Titulos-Negociaveis/DetalheTitulosNegociaveis.aspx"
  @price_path "/InstDados/SerHist"

  @doc """
  Gets data on index of listed companies page
  and returns the hole HTML structure
  """
  @impl true
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
  @impl true
  def get_item(code) do
    [or: "res", cb: code]
    |> client()
    |> Tesla.get(@details_path)
    |> handle_response()
  end

  @doc """
  Download zip file contents from historical quotes website
  (http://www.b3.com.br/en_us/market-data-and-indices/data-services/market-data/historical-data/equities/historical-quotes/)

  You can retrieve a hole year, hole month or a specific day
  by providing one, two and three arguments respectively
  """
  @impl true
  def get_historical_file(year, month, day), do: download_file("D#{day}#{month}#{year}")

  @impl true
  def get_historical_file(year, month), do: download_file("M#{month}#{year}")

  @impl true
  def get_historical_file(year), do: download_file("A#{year}")

  defp download_file(file_name) do
    "#{@base_url}#{@price_path}/COTAHIST_#{file_name}.ZIP"
    |> Tesla.get()
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
