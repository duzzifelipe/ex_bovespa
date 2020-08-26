defmodule ExBovespa.Helpers.StringHelperTest do
  use ExUnit.Case

  alias ExBovespa.Helpers.StringHelper

  describe "remove_blank_spaces/1" do
    test "should escape multiline string with spaces and breaks" do
      assert StringHelper.remove_blank_spaces("""
             My
             Test
                 String
             With
              Strange
             alignment
             """) == "My Test String With Strange alignment"
    end
  end
end
