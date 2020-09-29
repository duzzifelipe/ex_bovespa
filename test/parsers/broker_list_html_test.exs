defmodule ExBovespa.Parsers.BrokerListHtmlTest do
  use ExUnit.Case

  alias ExBovespa.Parsers.BrokerListHtml
  alias ExBovespa.Structs.Broker

  describe "parse/1" do
    test "should return items and pagination" do
      assert %{
               current_page: 3,
               total_pages: 5,
               items: [
                 %Broker{code: 979, name: "ADVALOR DTVM LTDA"},
                 %Broker{code: 39, name: "AGORA CTVM S/A"},
                 %Broker{code: 4, name: "ALFA CCVM S.A."},
                 %Broker{code: 226, name: "AMARIL FRANKLIN CTV LTDA."},
                 %Broker{code: 147, name: "ATIVA INVESTIMENTOS S.A. CTCV"},
                 %Broker{code: 4002, name: "BANCO ANDBANK (BRASIL) S.A."},
                 %Broker{code: 251, name: "BANCO BNP PARIBAS BRASIL S/A"},
                 %Broker{code: 1116, name: "BANCO CITIBANK"},
                 %Broker{code: 359, name: "BANCO DAYCOVAL"},
                 %Broker{code: 683, name: "BANCO MODAL"}
               ]
             } = BrokerListHtml.parse(big_complete_tree())
    end
  end

  defp big_complete_tree do
    """
    <html>
      <body>
        <div class="lum-content">
          <div class="lum-content-body">
            <div class="large-12 columns">
              <div class="row">
                <div class="large-8 columns">
                  <div class="row corretoras">
                    <div class="large-3 columns">
                      <div class="logo-corretora">
                        <p><img alt="" id="logo_979" src="./Busca de corretoras _ B3_files/logo_979_advalor.png">
                        </p>
                      </div>
                    </div>
                    <div class="large-9 columns">
                      <h6 class="subheader"><a
                          href="http://www.b3.com.br/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/advalor-dtvm-ltda.htm">ADVALOR
                          DTVM LTDA - 979</a></h6>
                    </div>
                  </div>
                  <hr>
                  <div class="row corretoras">
                    <div class="large-3 columns">
                      <div class="logo-corretora">
                        <p><img alt="" id="logo_39" src="./Busca de corretoras _ B3_files/logo-agora.jpg"></p>
                      </div>
                    </div>
                    <div class="large-9 columns">
                      <h6 class="subheader"><a
                          href="http://www.b3.com.br/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/agora-ctvm-s-a.htm">AGORA
                          CTVM S/A - 39</a></h6>
                    </div>
                  </div>
                  <hr>
                  <div class="row corretoras">
                    <div class="large-3 columns">
                      <div class="logo-corretora">
                        <p><img alt="" id="logo_4" src="./Busca de corretoras _ B3_files/logo_4_alfa.png"></p>
                      </div>
                    </div>
                    <div class="large-9 columns">
                      <h6 class="subheader"><a
                          href="http://www.b3.com.br/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/alfa-ccvm-s-a.htm">ALFA
                          CCVM S.A. - 4</a></h6>
                    </div>
                  </div>
                  <hr>
                  <div class="row corretoras">
                    <div class="large-3 columns">
                      <div class="logo-corretora">
                        <p><img alt="" id="logo_226" src="./Busca de corretoras _ B3_files/logo_226_amaril.png">
                        </p>
                      </div>
                    </div>
                    <div class="large-9 columns">
                      <h6 class="subheader"><a
                          href="http://www.b3.com.br/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/amaril-franklin-ctv-ltda.htm">AMARIL
                          FRANKLIN CTV LTDA. - 226</a></h6>
                    </div>
                  </div>
                  <hr>
                  <div class="row corretoras">
                    <div class="large-3 columns">
                      <div class="logo-corretora">
                        <p><img alt="" id="logo_147" src="./Busca de corretoras _ B3_files/logo_147_ativa.png">
                        </p>
                      </div>
                    </div>
                    <div class="large-9 columns">
                      <h6 class="subheader"><a
                          href="http://www.b3.com.br/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/ativa-investimentos-s-a-ctcv.htm">ATIVA
                          INVESTIMENTOS S.A. CTCV - 147</a></h6>
                    </div>
                  </div>
                  <hr>
                  <div class="row corretoras">
                    <div class="large-3 columns">
                      <div class="logo-corretora">
                        <p><img alt="" id="logo_4.002"
                            src="./Busca de corretoras _ B3_files/Logo_Andbank 780x200.jpg"></p>
                      </div>
                    </div>
                    <div class="large-9 columns">
                      <h6 class="subheader"><a
                          href="http://www.b3.com.br/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/banco-andbank-brasil-s-a.htm">BANCO
                          ANDBANK (BRASIL) S.A. - 4.002</a></h6>
                    </div>
                  </div>
                  <hr>
                  <div class="row corretoras">
                    <div class="large-3 columns">
                      <div class="logo-corretora">
                        <p><img alt="" id="logo_251"
                            src="./Busca de corretoras _ B3_files/logo_251_bnpparibas.png"></p>
                      </div>
                    </div>
                    <div class="large-9 columns">
                      <h6 class="subheader"><a
                          href="http://www.b3.com.br/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/banco-bnp-paribas-brasil-s-a.htm">BANCO
                          BNP PARIBAS BRASIL S/A - 251</a></h6>
                    </div>
                  </div>
                  <hr>
                  <div class="row corretoras">
                    <div class="large-3 columns">
                      <div class="logo-corretora" id="logoInd_1.116">
                        <p><img alt="" src="./Busca de corretoras _ B3_files/logo_nao_disponivel.png"></p>
                      </div>
                    </div>
                    <div class="large-9 columns">
                      <h6 class="subheader"><a
                          href="http://www.b3.com.br/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/banco-citibank.htm">BANCO
                          CITIBANK - 1.116</a></h6>
                    </div>
                  </div>
                  <hr>
                  <div class="row corretoras">
                    <div class="large-3 columns">
                      <div class="logo-corretora">
                        <p><img alt="" id="logo_359" src="./Busca de corretoras _ B3_files/logo_359_daycoval.png">
                        </p>
                      </div>
                    </div>
                    <div class="large-9 columns">
                      <h6 class="subheader"><a
                          href="http://www.b3.com.br/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/banco-daycoval.htm">BANCO
                          DAYCOVAL - 359</a></h6>
                    </div>
                  </div>
                  <hr>
                  <div class="row corretoras">
                    <div class="large-3 columns">
                      <div class="logo-corretora">
                        <p><img alt="" id="logo_683" src="./Busca de corretoras _ B3_files/logo_683_modal.png">
                        </p>
                      </div>
                    </div>
                    <div class="large-9 columns">
                      <h6 class="subheader"><a
                          href="http://www.b3.com.br/pt_br/produtos-e-servicos/participantes/busca-de-participantes/busca-de-corretoras/banco-modal.htm">BANCO
                          MODAL - 683</a></h6>
                    </div>
                  </div>
                  <div class="row">
                    <div class="large-5 large-centered columns text-center">
                      <ul class="pagination">
                        <li class="arrow unavailable"><a href="">«</a></li>
                        <li><a href="">1</a>
                        </li>
                        <li><a href="">2</a>
                        </li>
                        <li class="current"><a href="">3</a>
                        </li>
                        <li><a href="">4</a>
                        </li>
                        <li><a href="">5</a>
                        </li>
                        <li class="arrow"><a href="">»</a>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </body>
    </html>
    """
  end
end
