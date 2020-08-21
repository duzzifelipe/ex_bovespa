defmodule ExBovespaTest do
  use ExUnit.Case
  doctest ExBovespa

  describe "stock_list/0" do
    test "returns nil by default" do
      assert is_nil(ExBovespa.stock_list())
    end
  end
end
