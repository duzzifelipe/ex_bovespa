defmodule ExBovespa.StatusInvestTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  import Mox

  alias ExBovespa.StatusInvest
  alias ExBovespa.Structs.{StatusInvestPrice, StatusInvestStock}

  describe "fii_list/0" do
    test "returns empty list from service" do
      expect(ExBovespa.Adapters.StatusInvestMock, :get_fii_list, fn ->
        {:ok, []}
      end)

      assert {:ok, []} = StatusInvest.fii_list()
    end

    test "returns list items" do
      expect(ExBovespa.Adapters.StatusInvestMock, :get_fii_list, fn ->
        {:ok,
         [
           %{
             "companyId" => 0,
             "companyName" => "INVEST",
             "url" => "/fundos-imobiliarios/inv11"
           }
         ]}
      end)

      assert {:ok,
              [
                %StatusInvestStock{code: "inv11", company_name: "INVEST", type: :fii}
              ]} == StatusInvest.fii_list()
    end

    test "returns http error from list service" do
      expect(ExBovespa.Adapters.StatusInvestMock, :get_fii_list, fn ->
        {:error, :invalid_response}
      end)

      assert capture_log(fn ->
               assert {:error, :invalid_response} = StatusInvest.fii_list()
             end) =~
               "[error] Elixir.ExBovespa.StatusInvest.fii_list error={:error, :invalid_response}"
    end
  end

  describe "stock_list/0" do
    test "returns empty list from service" do
      expect(ExBovespa.Adapters.StatusInvestMock, :get_stock_list, fn ->
        {:ok, []}
      end)

      assert {:ok, []} = StatusInvest.stock_list()
    end

    test "returns list items" do
      expect(ExBovespa.Adapters.StatusInvestMock, :get_stock_list, fn ->
        {:ok,
         [
           %{
             "companyId" => 0,
             "companyName" => "INVEST",
             "url" => "/acoes/inv4"
           }
         ]}
      end)

      assert {:ok,
              [
                %StatusInvestStock{code: "inv4", company_name: "INVEST", type: :stock}
              ]} == StatusInvest.stock_list()
    end

    test "returns http error from list service" do
      expect(ExBovespa.Adapters.StatusInvestMock, :get_stock_list, fn ->
        {:error, :invalid_response}
      end)

      assert capture_log(fn ->
               assert {:error, :invalid_response} = StatusInvest.stock_list()
             end) =~
               "[error] Elixir.ExBovespa.StatusInvest.stock_list error={:error, :invalid_response}"
    end
  end

  describe "get_price/2" do
    test "returns empty list from service" do
      expect(ExBovespa.Adapters.StatusInvestMock, :get_stock_price, fn "CODE4", "-1" ->
        {:ok, %{"prices" => []}}
      end)

      assert {:ok, []} = StatusInvest.get_price("CODE4", :one_day)
    end

    test "returns list items for valid filters and short term returning naive datetime" do
      filter_to_type = %{one_day: "-1", five_days: "0"}
      valid_filters = ~w/one_day five_days/a

      for filter <- valid_filters do
        code = :crypto.strong_rand_bytes(6)

        expect(ExBovespa.Adapters.StatusInvestMock, :get_stock_price, fn ^code, type ->
          assert type == filter_to_type[filter]

          {:ok, %{"prices" => [%{"price" => 104.39, "date" => "14/09/20 10:00"}]}}
        end)

        price = Decimal.from_float(104.39)

        assert {:ok, [%StatusInvestPrice{price: ^price, date: ~N[2020-09-14 10:00:00]}]} =
                 StatusInvest.get_price(code, filter)
      end
    end

    test "returns list items for valid filters and short term returning date" do
      filter_to_type = %{one_month: "1", six_months: "2", one_year: "3", five_years: "4"}
      valid_filters = ~w/one_month six_months one_year five_years/a

      for filter <- valid_filters do
        code = :crypto.strong_rand_bytes(6)

        expect(ExBovespa.Adapters.StatusInvestMock, :get_stock_price, fn ^code, type ->
          assert type == filter_to_type[filter]

          {:ok, %{"prices" => [%{"price" => 104.39, "date" => "14/09/20 10:00"}]}}
        end)

        price = Decimal.from_float(104.39)

        assert {:ok, [%StatusInvestPrice{price: ^price, date: ~D[2020-09-14]}]} =
                 StatusInvest.get_price(code, filter)
      end
    end

    test "returns error for invalid filters" do
      invalid_filters = ~w/two_days three_months five_months two_years ten_years/a

      for filter <- invalid_filters do
        code = :crypto.strong_rand_bytes(6)

        expect(ExBovespa.Adapters.StatusInvestMock, :get_stock_price, fn ^code, nil ->
          {:error, :invalid_parameters}
        end)

        assert capture_log(fn ->
                 assert {:error, :invalid_parameters} = StatusInvest.get_price(code, filter)
               end) =~
                 "[error] Elixir.ExBovespa.StatusInvest.get_price error={:error, :invalid_parameters}"
      end
    end

    test "returns http error from service" do
      expect(ExBovespa.Adapters.StatusInvestMock, :get_stock_price, fn "CODE4", "-1" ->
        {:error, :invalid_response}
      end)

      assert capture_log(fn ->
               assert {:error, :invalid_response} = StatusInvest.get_price("CODE4", :one_day)
             end) =~
               "[error] Elixir.ExBovespa.StatusInvest.get_price error={:error, :invalid_response}"
    end
  end
end
