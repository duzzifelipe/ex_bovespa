defmodule ExBovespa.Parsers.StockDetailDataTest do
  use ExUnit.Case

  alias ExBovespa.Parsers.StockDetailData
  alias ExBovespa.Structs.Stock

  describe "parse_description/2" do
    test "should parse all :bdr possibilities" do
      for description <- ["DRN", "DRN   ", "DRN ED"] do
        assert :bdr = StockDetailData.parse_description(description, %Stock{})
      end
    end

    test "should parse all :stock possibilities" do
      for description <- [
            "ON",
            "ON   ",
            "ON      N1",
            "ON      NM",
            "PN",
            "PN   ",
            "PN      N1",
            "PNA",
            "PNR",
            "PNB",
            "PNA     MB",
            "DR3",
            "DR3    ",
            "UNT",
            "UNT     N2"
          ] do
        assert :stock = StockDetailData.parse_description(description, %Stock{})
      end
    end

    test "should parse all :fidc possibilities" do
      for description <- ["FIDC", "FIDC   ", "FIDC    MB"] do
        assert :fidc = StockDetailData.parse_description(description, %Stock{})
      end
    end

    test "should parse all :fii possibilities" do
      for description <- ["CI", "CI   ", "", "ANY STR"],
          stock <- [
            %Stock{short_name: "FII ATRIO"},
            %Stock{short_name: "FII FATOR VE"},
            %Stock{short_name: "ANOTHER FII NAME"}
          ] do
        assert :fii = StockDetailData.parse_description(description, stock)
      end
    end

    test "should parse all :etf possibilities" do
      for description <- ["ANY", "  STRING", "", "MATCH   "],
          stock <- [
            %Stock{name: "ETF NAME", short_name: ""},
            %Stock{name: "NAME OF ETF", short_name: ""},
            %Stock{name: "IT NOW NAME", short_name: ""},
            %Stock{name: "NAME OF IT NOW", short_name: ""},
            %Stock{name: "ISHARES NAME", short_name: ""},
            %Stock{name: "NAME OF ISHARES", short_name: ""}
          ] do
        assert :etf = StockDetailData.parse_description(description, stock)
      end
    end

    test "should parse all :fund possibilities" do
      for description <- ["ANY", "  STRING", "", "MATCH   "],
          stock <- [
            %Stock{name: "FDO INVESTIMENTOS", short_name: ""},
            %Stock{name: "NAME OF FDO INVESTIMENTOS IMOB", short_name: ""}
          ] do
        assert :fund = StockDetailData.parse_description(description, stock)
      end
    end

    test "should parse all :index possibilities" do
      for description <- ["ANY", "  STRING", "", "MATCH   "],
          stock <- [
            %Stock{name: "INDICE BOVESPA", short_name: ""},
            %Stock{name: "NOVO INDICE IMOBILIARIO", short_name: ""},
            %Stock{name: "ÍNDICE BOVESPA", short_name: ""},
            %Stock{name: "NOVO ÍNDICE IMOBILIARIO", short_name: ""}
          ] do
        assert :index = StockDetailData.parse_description(description, stock)
      end
    end

    test "all remaining should be nil" do
      for description <- ["ANY", "  STRING", "", "MATCH   "],
          stock <- [
            %Stock{name: "BITCOIN", short_name: ""},
            %Stock{name: "BOVESPA", short_name: ""},
            %Stock{name: "S&P500", short_name: ""}
          ] do
        assert is_nil(StockDetailData.parse_description(description, stock))
      end
    end
  end
end
