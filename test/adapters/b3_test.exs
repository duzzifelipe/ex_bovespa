defmodule ExBovespa.Adapters.B3Test do
  use ExUnit.Case

  import Tesla.Mock

  alias ExBovespa.Adapters.B3

  @base_url "http://www.b3.com.br"
  @list_url @base_url <>
              "/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/"

  describe "get_company_list_by_page/1" do
    test "should return the html content if status is 200" do
      page_num = Enum.random(1..20)

      mock(fn %{method: :post, url: @list_url, headers: headers, body: body} ->
        assert [
                 {"Upgrade-Insecure-Requests", "1"},
                 {"Origin", "http://www.b3.com.br"},
                 {"Content-Type", "application/x-www-form-urlencoded"},
                 {"User-Agent",
                  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.59 Safari/537.36"},
                 {"Accept",
                  "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"},
                 {"Accept-Language", "en-US,en;q=0.9"},
                 {"Referer", @list_url},
                 {"content-type", "application/x-www-form-urlencoded"}
               ] = headers

        assert body ==
                 "lumA=&lumClientMessage=&lumDataPreviewMode=&lumI=&lumII=8A488AEB50447C8F0150489E91DF396A&lumNewParams=%3Cparameters+destId%3D%228A488AEB50447C8F0150489E91DF396A%22+destType%3D%22lumII%22%3E%3Cp+n%3D%22lumFromForm%22%3EForm_8A488AEB50447C8F0150489E91DF396A%3C%2Fp%3E%3Cp+n%3D%22lumFormAction%22%3Ehttp%3A%2F%2Fwww.b3.com.br%2Fmain.jsp%3FlumPageId%3D8A488AEB50447C8F0150489E6D883938%26amp%3BlumA%3D1%26amp%3BlumII%3D8A488AEB50447C8F0150489E91DF396A%3C%2Fp%3E%3Cp+n%3D%22doui_fromForm%22%3EForm_8A488AEB50447C8F0150489E91DF396A%3C%2Fp%3E%3Cp+n%3D%22lumII%22%3E8A488AEB50447C8F0150489E91DF396A%3C%2Fp%3E%3Cp+n%3D%22pagination%22%3E#{
                   page_num
                 }%3C%2Fp%3E%3Cp+n%3D%22bvmf-locales-content%22%3Ept_BR%2Cen_US%2Ces%3C%2Fp%3E%3C%2Fparameters%3E&lumPageOriginalUrl=main.jsp%3FlumPageId%3D8A488AEB50447C8F0150489E6D883938&lumPrevParams=%253CallParameters%253E%253Cparameters%253E%253Cp%2Bn%253D%2522lumChannelId%2522%253E8A488AEB5023BDF8015023CE00B21642%253C%252Fp%253E%253C%252Fparameters%253E%253C%252FallParameters%253E&lumPrinting=&lumReplIntfState=&lumS=&lumSI=&lumSafeRenderMode=&lumToggleModeOriginUrl="

        %Tesla.Env{status: 200, body: "<html></html>"}
      end)

      assert {:ok, "<html></html>"} = B3.get_company_list_by_page(page_num)
    end

    test "should return error for other statuses" do
      statuses = Enum.to_list(100..199) ++ Enum.to_list(201..599)

      for status <- statuses do
        mock(fn %{method: :post, url: @list_url} ->
          %Tesla.Env{status: status, body: ""}
        end)

        assert {:error, :invalid_response} = B3.get_company_list_by_page(Enum.random(1..20))
      end
    end
  end
end
