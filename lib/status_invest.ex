defmodule ExBovespa.StatusInvest do
  @moduledoc """
  Exposes data from https://statusinvest.com.br/ website
  """

  alias ExBovespa.Structs.{StatusInvestPrice, StatusInvestStock}

  require Logger

  @adapter_module Application.get_env(
                    :ex_bovespa,
                    :status_invest_adapter,
                    ExBovespa.Adapters.StatusInvest
                  )

  @doc """
  Returns a list of all available FII codes
  on statusinvest website alongside the issuer
  company's name

  ### Example

      iex> ExBovespa.StatusInvest.fii_list()
      {:ok, [
        %StatusInvestStock{
          company_name: "My issuer company",
          type: :fii,
          code: "CODE11"
        }
      ]}
  """
  @spec fii_list :: {:ok, list(StatusInvestStock.t())} | {:error, :invalid_response}
  def fii_list do
    Logger.debug("#{__MODULE__}.fii_list")

    case @adapter_module.get_fii_list() do
      {:ok, json} ->
        {:ok, parse_list_items(json, :fii)}

      error ->
        Logger.error("#{__MODULE__}.fii_list error=#{inspect(error)}")
        error
    end
  end

  @doc """
  Returns a list of all available stock codes
  on statusinvest website and the related company's name

  ### Example

      iex> ExBovespa.StatusInvest.stock_list()
      {:ok, [
        %StatusInvestStock{
          company_name: "My company",
          type: :stock,
          code: "CODE4"
        }
      ]}
  """
  @spec stock_list :: {:ok, list(StatusInvestStock.t())} | {:error, :invalid_response}
  def stock_list do
    Logger.debug("#{__MODULE__}.stock_list")

    case @adapter_module.get_stock_list() do
      {:ok, json} ->
        {:ok, parse_list_items(json, :stock)}

      error ->
        Logger.error("#{__MODULE__}.stock_list error=#{inspect(error)}")
        error
    end
  end

  defp parse_list_items(json, type) do
    Enum.map(json, fn item ->
      %StatusInvestStock{
        company_name: Map.get(item, "companyName"),
        type: type,
        code: item |> Map.get("url") |> String.split("/") |> Enum.at(-1)
      }
    end)
  end

  @doc """
  Returns a list of prices for a specific
  code (either for FII and Stock).

  The range can be:
   - one_day or five_days that will return a NaiveDateTime (brings the second)
   - one_month, six_months, one_year, five_years (brings data related to days)

  ### Example

      iex> ExBovespa.StatusInvest.get_price("CODE11", :one_month)
      {:ok, [
        %StatusInvestPrice{
          date: ~D[2020-09-17],
          price: #Decimal<14.41>
        }
      ]}

      iex> ExBovespa.StatusInvest.get_price("CODE11", :one_day)
      {:ok, [
        %StatusInvestPrice{
          date: ~N[2020-09-17 14:30:00],
          price: #Decimal<25.19>
        }
      ]}
  """
  @spec get_price(
          code :: String.t(),
          range :: :one_day | :five_days | :one_month | :six_months | :one_year | :five_years
        ) ::
          {:ok, list(StatusInvestPrice.t())}
          | {:error, :invalid_response}
          | {:error, :invalid_parameters}
  def get_price(code, range) do
    Logger.debug("#{__MODULE__}.get_price")

    case @adapter_module.get_stock_price(code, parse_range(range)) do
      {:ok, json} ->
        {:ok, json |> Map.get("prices") |> Enum.map(&build_price(&1, range))}

      error ->
        Logger.error("#{__MODULE__}.get_price error=#{inspect(error)}")
        error
    end
  end

  defp parse_range(:one_day), do: "-1"
  defp parse_range(:five_days), do: "0"
  defp parse_range(:one_month), do: "1"
  defp parse_range(:six_months), do: "2"
  defp parse_range(:one_year), do: "3"
  defp parse_range(:five_years), do: "4"
  defp parse_range(_invalid), do: nil

  defp build_price(row, range) do
    date = row |> Map.get("date") |> Timex.parse!("{D}/{M}/{YY} {h24}:{m}")

    date =
      if(range == :one_day or range == :five_days, do: date, else: NaiveDateTime.to_date(date))

    %StatusInvestPrice{
      date: date,
      price: row |> Map.get("price") |> Decimal.from_float() |> Decimal.round(2)
    }
  end
end
