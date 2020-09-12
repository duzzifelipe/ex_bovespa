defmodule ExBovespa.Adapters.B3 do
  @moduledoc """
  Retrieves data from B3"s website on brokers path
  """

  @behaviour ExBovespa.Adapters.B3Behaviour

  @base_url "http://www.b3.com.br"
  @base_path "/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/"
  @files_base_url "https://arquivos.b3.com.br/apinegocios/ticker"

  @doc """
  Do a post request on list page with needed parameters for pagination
  """
  @impl true
  def get_company_list_by_page(page) do
    www_client()
    |> Tesla.post(@base_path, body(page))
    |> handle_response()
  end

  @doc """
  Makes a request to the page that shows a price
  table for a stock on a specific date
  """
  @impl true
  def get_stock_price(code, %Date{} = date) do
    json_client()
    |> Tesla.get("/#{code}/#{date}")
    |> handle_response()
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_response(_), do: {:error, :invalid_response}

  defp body(page) do
    dest_id = "8A488AEB50447C8F0150489E91DF396A"
    page_id = "8A488AEB50447C8F0150489E6D883938"

    # urlencoded
    %{
      "lumNewParams" =>
        ~s(<parameters destId="#{dest_id}" destType="lumII"><p n="lumFromForm">Form_#{dest_id}</p><p n="lumFormAction">http://www.b3.com.br/main.jsp?lumPageId=#{
          page_id
        }&amp;lumA=1&amp;lumII=#{dest_id}</p><p n="doui_fromForm">Form_#{dest_id}</p><p n="lumII">#{
          dest_id
        }</p><p n="pagination">#{page}</p><p n="bvmf-locales-content">pt_BR,en_US,es</p></parameters>),
      "lumPrinting" => "",
      "lumToggleModeOriginUrl" => "",
      "lumSafeRenderMode" => "",
      "lumPageOriginalUrl" => "main.jsp?lumPageId=#{page_id}",
      "lumS" => "",
      "lumSI" => "",
      "lumI" => "",
      "lumII" => "#{dest_id}",
      "lumReplIntfState" => "",
      "lumPrevParams" =>
        "%3CallParameters%3E%3Cparameters%3E%3Cp+n%3D%22lumChannelId%22%3E8A488AEB5023BDF8015023CE00B21642%3C%2Fp%3E%3C%2Fparameters%3E%3C%2FallParameters%3E",
      "lumA" => "",
      "lumDataPreviewMode" => "",
      "lumClientMessage" => ""
    }
  end

  defp www_client do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.Headers, headers()},
      Tesla.Middleware.FormUrlencoded
    ])
  end

  defp json_client do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @files_base_url},
      Tesla.Middleware.JSON
    ])
  end

  defp headers do
    [
      {"Upgrade-Insecure-Requests", "1"},
      {"Origin", "http://www.b3.com.br"},
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"User-Agent",
       "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.59 Safari/537.36"},
      {"Accept",
       "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"},
      {"Accept-Language", "en-US,en;q=0.9"},
      {"Referer", @base_url <> @base_path}
    ]
  end
end
