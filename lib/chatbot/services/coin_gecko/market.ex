defmodule Chatbot.Service.CoinGecko.Market do
  alias Chatbot.Service.CoinGecko.Client

  def search(coin_id) do
    url = url(:search, coin_id)

    case Client.request(:get, url) do
      {:ok, response} ->
        {selected_coins, _} =
          response.body["coins"]
          |> Enum.split(5)

        {:ok, selected_coins}
      {:error, error} ->
        {:error, error}
    end
  end

  def market_chart(coin_id) do
    url = url(:market_chart, coin_id)

    case Client.request(:get, url) do
      {:ok, response} ->
        {:ok, response.body}
      {:error, error} ->
        {:error, error}
    end
  end

  defp url(:search, coin_id),
   do: "search?query=#{coin_id}"

  defp url(:market_chart, coin_id),
   do: "coins/#{coin_id}/market_chart?vs_currency=usd&days=14&interval=daily"
end
