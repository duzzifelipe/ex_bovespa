defmodule ExBovespa.Adapters.StatusInvestTest do
  use ExUnit.Case

  import Tesla.Mock

  alias ExBovespa.Adapters.StatusInvest

  @fii_list_url "https://statusinvest.com.br/fii/fundsnavigation"
  @fii_list_query [page: 1, size: 10_000]

  @stock_list_url "https://statusinvest.com.br/acao/companiesnavigation"
  @stock_list_query [page: 1, size: 10_000]

  @price_url "https://statusinvest.com.br/category/tickerprice"

  describe "get_fii_list/0" do
    test "should return the json content as map if status is 200" do
      mock(fn %{method: :get, url: @fii_list_url, query: @fii_list_query} ->
        %Tesla.Env{
          status: 200,
          body:
            Jason.decode!(
              ~S([{"companyId":0,"companyName":"INVEST","url":"/fundos-imobiliarios/inv11"}])
            )
        }
      end)

      assert {:ok,
              [
                %{
                  "companyId" => 0,
                  "companyName" => "INVEST",
                  "url" => "/fundos-imobiliarios/inv11"
                }
              ]} = StatusInvest.get_fii_list()
    end

    test "should return error for other statuses" do
      statuses = Enum.to_list(100..199) ++ Enum.to_list(201..599)

      for status <- statuses do
        mock(fn %{method: :get, url: @fii_list_url, query: @fii_list_query} ->
          %Tesla.Env{status: status, body: ""}
        end)

        assert {:error, :invalid_response} = StatusInvest.get_fii_list()
      end
    end
  end

  describe "get_stock_list/0" do
    test "should return the json content as map if status is 200" do
      mock(fn %{method: :get, url: @stock_list_url, query: @stock_list_query} ->
        %Tesla.Env{
          status: 200,
          body: Jason.decode!(~S([{"companyId":0,"companyName":"INVEST","url":"/acoes/inv4"}]))
        }
      end)

      assert {:ok,
              [
                %{
                  "companyId" => 0,
                  "companyName" => "INVEST",
                  "url" => "/acoes/inv4"
                }
              ]} = StatusInvest.get_stock_list()
    end

    test "should return error for other statuses" do
      statuses = Enum.to_list(100..199) ++ Enum.to_list(201..599)

      for status <- statuses do
        mock(fn %{method: :get, url: @stock_list_url, query: @stock_list_query} ->
          %Tesla.Env{status: status, body: ""}
        end)

        assert {:error, :invalid_response} = StatusInvest.get_stock_list()
      end
    end
  end

  describe "get_stock_price/2" do
    test "should retrieve with valid filters" do
      valid_range = Enum.map(Range.new(-1, 4), &to_string/1)

      for filter <- valid_range do
        code = :crypto.strong_rand_bytes(6)

        mock(fn %{method: :get, url: @price_url, query: [ticker: ^code, type: ^filter]} ->
          %Tesla.Env{
            status: 200,
            body: Jason.decode!(~S({"prices": [{"price":104.39,"date":"14/09/20 10:00"}]}))
          }
        end)

        assert {:ok, %{"prices" => [%{"price" => 104.39, "date" => "14/09/20 10:00"}]}} =
                 StatusInvest.get_stock_price(code, filter)
      end
    end

    test "should return error for invalid filter" do
      range_before = Range.new(-12, -2)
      range_after = Range.new(5, 15)
      valid_range = range_before |> Enum.concat(range_after) |> Enum.map(&to_string/1)

      for filter <- valid_range do
        code = :crypto.strong_rand_bytes(6)
        assert {:error, :invalid_parameters} = StatusInvest.get_stock_price(code, filter)
      end
    end

    test "should return error for other statuses" do
      statuses = Enum.to_list(100..199) ++ Enum.to_list(201..599)

      for status <- statuses do
        mock(fn %{method: :get, url: @price_url, query: [ticker: "CODE4", type: "0"]} ->
          %Tesla.Env{status: status, body: ""}
        end)

        assert {:error, :invalid_response} = StatusInvest.get_stock_price("CODE4", "0")
      end
    end
  end
end
