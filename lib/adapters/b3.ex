defmodule ExBovespa.Adapters.B3 do
  @moduledoc """
  Retrieves data from B3"s website on brokers path
  """

  @behaviour ExBovespa.Adapters.B3Behaviour

  require Logger

  @base_url "https://sistemaswebb3-listados.b3.com.br"
  @base_path "/participantsProxy/participantCall/GetInitialParticipants/<query>"

  @doc """
  Do a post request on list page with needed parameters for pagination
  """
  @impl true
  def get_company_list do
    encoded_query = generate_page_query(1, 500)
    path = String.replace(@base_path, "<query>", encoded_query)

    client()
    |> Tesla.get(path)
    |> handle_response()
  end

  defp generate_page_query(page, limit) do
    %{
      pageNumber: page,
      pageSize: limit,
      categories: "3",
      seals: "",
      name: "",
      document: "",
      code: ""
    }
    |> Jason.encode!()
    |> Base.encode64()
  end

  defp handle_response({:ok, %Tesla.Env{status: 200, body: body}}) do
    {:ok, Map.fetch!(body, "results")}
  end

  defp handle_response(error) do
    Logger.error("#{__MODULE__}.handle_response error=#{inspect(error)}")
    {:error, :invalid_response}
  end

  defp client do
    Tesla.client([
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BaseUrl, @base_url},
      {Tesla.Middleware.Headers, headers()}
    ])
  end

  defp headers do
    [
      {"Upgrade-Insecure-Requests", "1"},
      {"Origin", "http://www.b3.com.br"},
      {"Content-Type", "application/json"},
      {"User-Agent",
       "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.59 Safari/537.36"},
      {"Accept", "application/json"},
      {"Accept-Language", "en-US,en;q=0.9"}
    ]
  end
end
