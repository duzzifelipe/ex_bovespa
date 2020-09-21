defmodule ExBovespa.Adapters.BovespaTest do
  use ExUnit.Case

  import Tesla.Mock

  alias ExBovespa.Adapters.Bovespa

  @base_url "http://bvmf.bmfbovespa.com.br"

  @list_url @base_url <> "/cias-listadas/Titulos-Negociaveis/ResumoTitulosNegociaveis.aspx"
  @list_query [or: "bus", tip: "N", cb: "", idioma: "pt-BR"]

  @details_url @base_url <> "/cias-listadas/Titulos-Negociaveis/DetalheTitulosNegociaveis.aspx"
  @details_query [or: "res", tip: "N", cb: "", idioma: "pt-BR"]

  @price_url @base_url <> "/InstDados/SerHist"

  describe "get_list/0" do
    test "should return the html content for yearly file if status is 200" do
      mock(fn %{method: :get, url: @list_url, query: @list_query} ->
        %Tesla.Env{status: 200, body: "<html></html>"}
      end)

      assert {:ok, "<html></html>"} = Bovespa.get_list()
    end

    test "should return error for other statuses" do
      statuses = Enum.to_list(100..199) ++ Enum.to_list(201..599)

      for status <- statuses do
        mock(fn %{method: :get, url: @list_url, query: @list_query} ->
          %Tesla.Env{status: status, body: ""}
        end)

        assert {:error, :invalid_response} = Bovespa.get_list()
      end
    end
  end

  describe "get_item/1" do
    test "should return the html content if status is 200" do
      query = Keyword.replace!(@details_query, :cb, "IBOV")

      mock(fn %{method: :get, url: @details_url, query: ^query} ->
        %Tesla.Env{status: 200, body: "<html></html>"}
      end)

      assert {:ok, "<html></html>"} = Bovespa.get_item("IBOV")
    end

    test "should return error for other statuses" do
      query = Keyword.replace!(@details_query, :cb, "IBOV")
      statuses = Enum.to_list(100..199) ++ Enum.to_list(201..599)

      for status <- statuses do
        mock(fn %{method: :get, url: @details_url, query: ^query} ->
          %Tesla.Env{status: status, body: ""}
        end)

        assert {:error, :invalid_response} = Bovespa.get_item("IBOV")
      end
    end
  end

  describe "get_historical_file/1" do
    test "should return binary content for monthly file if status is 200" do
      year = to_string(Enum.random(1970..2050))
      url = @price_url <> "/COTAHIST_A#{year}.ZIP"

      mock(fn %{method: :get, url: ^url} ->
        %Tesla.Env{status: 200, body: "data"}
      end)

      assert {:ok, "data"} = Bovespa.get_historical_file(year)
    end

    test "should return error for other statuses" do
      statuses = Enum.to_list(100..199) ++ Enum.to_list(201..599)

      for status <- statuses do
        year = to_string(Enum.random(1970..2050))
        url = @price_url <> "/COTAHIST_A#{year}.ZIP"

        mock(fn %{method: :get, url: ^url} ->
          %Tesla.Env{status: status, body: ""}
        end)

        assert {:error, :invalid_response} = Bovespa.get_historical_file(year)
      end
    end
  end

  describe "get_historical_file/2" do
    test "should return binary content if status is 200" do
      year = to_string(Enum.random(1970..2050))
      month = to_string(Enum.random(1..12))
      url = @price_url <> "/COTAHIST_M#{month}#{year}.ZIP"

      mock(fn %{method: :get, url: ^url} ->
        %Tesla.Env{status: 200, body: "data"}
      end)

      assert {:ok, "data"} = Bovespa.get_historical_file(year, month)
    end

    test "should return error for other statuses" do
      statuses = Enum.to_list(100..199) ++ Enum.to_list(201..599)

      for status <- statuses do
        year = to_string(Enum.random(1970..2050))
        month = to_string(Enum.random(1..12))
        url = @price_url <> "/COTAHIST_M#{month}#{year}.ZIP"

        mock(fn %{method: :get, url: ^url} ->
          %Tesla.Env{status: status, body: ""}
        end)

        assert {:error, :invalid_response} = Bovespa.get_historical_file(year, month)
      end
    end
  end

  describe "get_historical_file/3" do
    test "should return binary content for daily file if status is 200" do
      year = to_string(Enum.random(1970..2050))
      month = to_string(Enum.random(1..12))
      day = to_string(Enum.random(1..31))
      url = @price_url <> "/COTAHIST_D#{day}#{month}#{year}.ZIP"

      mock(fn %{method: :get, url: ^url} ->
        %Tesla.Env{status: 200, body: "data"}
      end)

      assert {:ok, "data"} = Bovespa.get_historical_file(year, month, day)
    end

    test "should return error for other statuses" do
      statuses = Enum.to_list(100..199) ++ Enum.to_list(201..599)

      for status <- statuses do
        year = to_string(Enum.random(1970..2050))
        month = to_string(Enum.random(1..12))
        day = to_string(Enum.random(1..31))
        url = @price_url <> "/COTAHIST_D#{day}#{month}#{year}.ZIP"

        mock(fn %{method: :get, url: ^url} ->
          %Tesla.Env{status: status, body: ""}
        end)

        assert {:error, :invalid_response} = Bovespa.get_historical_file(year, month, day)
      end
    end
  end
end
