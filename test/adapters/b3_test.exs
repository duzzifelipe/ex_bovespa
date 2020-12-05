defmodule ExBovespa.Adapters.B3Test do
  use ExUnit.Case

  import Tesla.Mock

  alias ExBovespa.Adapters.B3

  @base_url "https://sistemaswebb3-listados.b3.com.br"
  @list_url "#{@base_url}/participantsProxy/participantCall/GetInitialParticipants/<query>"

  describe "get_company_list/0" do
    test "should return the json result if status is 200" do
      query =
        %{
          pageNumber: 1,
          pageSize: 500,
          categories: "3",
          seals: "",
          name: "",
          document: "",
          code: ""
        }
        |> Jason.encode!()
        |> Base.encode64()

      list_url = String.replace(@list_url, "<query>", query)

      mock(fn %{method: :get, url: ^list_url, headers: headers} ->
        assert [
                 {"Upgrade-Insecure-Requests", "1"},
                 {"Origin", "http://www.b3.com.br"},
                 {"Content-Type", "application/json"},
                 {"User-Agent",
                  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.59 Safari/537.36"},
                 {"Accept", "application/json"},
                 {"Accept-Language", "en-US,en;q=0.9"}
               ] = headers

        %Tesla.Env{status: 200, body: %{"results" => []}}
      end)

      assert {:ok, []} = B3.get_company_list()
    end

    test "should return error for other statuses" do
      statuses = Enum.to_list(100..199) ++ Enum.to_list(201..599)

      for status <- statuses do
        mock(fn %{method: :get, url: _} ->
          %Tesla.Env{status: status, body: ""}
        end)

        assert {:error, :invalid_response} = B3.get_company_list()
      end
    end
  end
end
