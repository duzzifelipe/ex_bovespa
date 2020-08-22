defmodule ExBovespa.Adapters.BovespaTest do
  use ExUnit.Case

  import Tesla.Mock

  alias ExBovespa.Adapters.Bovespa

  @base_url "http://bvmf.bmfbovespa.com.br/cias-listadas/Titulos-Negociaveis"

  @list_url @base_url <> "/ResumoTitulosNegociaveis.aspx"
  @list_query [or: "bus", tip: "N", cb: "", idioma: "pt-BR"]

  @details_url @base_url <> "/DetalheTitulosNegociaveis.aspx"
  @details_query [or: "res", tip: "N", cb: "", idioma: "pt-BR"]

  describe "get_list/0" do
    test "should return the html content if status is 200" do
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
end
