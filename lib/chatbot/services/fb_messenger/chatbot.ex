defmodule Chatbot.Service.FacebookMessenger.Chatbot do
  alias Chatbot.Service.FacebookMessenger.Session
  alias Chatbot.Service.CoinGecko.Market, as: CGMarket

  def handle_message(text \\ "", psid, type \\ nil) do
    text
    |> String.downcase()
    |> response(psid, type)
  end

  defp response(text, psid, type) do
    case Session.get(psid) do
      {:ok, _} ->
        do_response(text, psid, type)
      {:error, _} ->
        do_greetings(text, psid)
    end
  end

  defp do_response(text, psid, type) do
    cond do
      String.match?(text, ~r/id/) and type == nil ->
        Session.insert(psid, text, true)
        %{
          type: "message",
          psid: psid,
          message: "Please enter coin id"
        }
      String.match?(text, ~r/coin_name/) and type == nil ->
        Session.insert(psid, text, true)
        %{
          type: "message",
          psid: psid,
          message: "Please enter coin name"
        }
      type == "id" ->
        Session.insert(psid, "id", true)
        do_search_by_coin_id(text, psid)
      type == "coin_name" ->
        Session.insert(psid, "coin_name", true)
        do_search_by_coin_name(text, psid)
      type == "show_results" ->
        do_coin_market_price_list(text, psid)
      String.match?(text, ~r/reset/) ->
        Session.delete(psid)
        do_greetings(text, psid)
      true ->
        %{
          type: "message",
          psid: psid,
          message: "Sorry, something went wrong"
        }
    end
  end

  defp do_greetings(text, psid) do
    case get_user_firstname(psid) do
      {:ok, firstname} ->
        Session.insert(text, psid)
        %{
          type: "new_session_search_selection",
          psid: psid,
          title: "Hey #{firstname}!",
          subtitle: "Select crypto coins searching method"
        }
      {:error, _} ->
        Session.insert(text, psid)
        %{
          type: "new_session_search_selection",
          psid: psid,
          title: "Hey crypto belieber ",
          subtitle: "Select crypto coins searching method"
        }
    end
  end

  defp do_search_by_coin_id(coin_id, psid) do
    case CGMarket.search(coin_id) do
      {:ok, coins} ->
        quick_replies =
          coins
          |> Enum.map(fn coin ->
            %{
              content_type: "text",
              title: coin["name"],
              payload: coin["id"],
              image_url: coin["thumb"]
            }
          end)

        %{
          type: "coins_selection",
          psid: psid,
          quick_replies: quick_replies
        }
      {:error, _} ->
        %{
          type: "message",
          psid: psid,
          message: "Sorry, something went wrong"
        }
    end
  end

  defp do_search_by_coin_name(coin_name, psid) do
    case CGMarket.search(coin_name) do
      {:ok, []} ->
        %{
          type: "message",
          psid: psid,
          message: "Sorry, something went wrong. Please try again."
        }
      {:ok, coins} ->
        quick_replies =
          coins
          |> Enum.map(fn coin ->
            %{
              content_type: "text",
              title: coin["name"],
              payload: coin["id"],
              image_url: coin["thumb"]
            }
          end)

        %{
          type: "coins_selection",
          psid: psid,
          quick_replies: quick_replies
        }
      {:error, _} ->
        %{
          type: "message",
          psid: psid,
          message: "Sorry, something went wrong. Please try again."
        }
    end
  end

  defp do_coin_market_price_list(coin_id, psid) do
    case CGMarket.market_chart(coin_id) do
      {:ok, %{"prices" => prices} = _} ->
        message =
          prices
          |> Enum.map(fn [date, price] ->
            date =
              Timex.from_unix(date, :millisecond)
              |> Timex.format!("{D}-{M}-{YYYY}")

            price = Float.round(price, 2)

            "Date: #{date} \n Price: $#{price} USD"
          end)
          |> Enum.join("\n\n")

          %{
            type: "message",
            psid: psid,
            message: message
          }
      {:error, _} ->
        %{
          type: "message",
          psid: psid,
          message: "Sorry, something went wrong. Please try again."
        }
    end
  end

  defp get_user_firstname(psid) do
    HTTPoison.start()

    case HTTPoison.get("https://graph.facebook.com/#{psid}?fields=first_name&access_token=#{Application.get_env(:chatbot, :fb_page_token)}") do
      {:ok, %{status_code: status_code} = response} when status_code == 200 ->
        {:ok, Jason.decode!(response.body)["first_name"]}
      {:ok, %{status_code: status_code} = _} when status_code != 200 ->
        {:error, :not_found}
      {:error, error} ->
        {:error, error}
    end
  end
end
