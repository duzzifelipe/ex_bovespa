defmodule ExBovespa.Helpers.StringHelper do
  @moduledoc """
  Functions that implement facilities
  for working with strings
  """

  @remove_blanks_regex ~r/\s+/

  @doc """
  Removes line breaks and repeated blanks from strings
  """
  def remove_blank_spaces(string) do
    @remove_blanks_regex
    |> Regex.replace(string, " ")
    |> String.trim()
  end
end
