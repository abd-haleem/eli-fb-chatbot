defmodule Chatbot.Service.FacebookMessenger.Message do
  alias Chatbot.Service.FacebookMessenger.Client

  def send_message(params) do
    body = message_structure(params)

    case Client.request(:post, "messages", body) do
      {:ok, %{status_code: status_code} = _} when status_code == 200 ->
        {:ok, :success}
      {:ok, %{status_code: status_code} = response} when status_code != 200 ->
        {:error, response.body["error"]}
      {:error, error} ->
        {:error, error}
    end
  end

  def message_structure(params) do
    case params.type do
      "message" ->
        %{
          recipient: %{
            id: params.psid
          },
          message: %{
            text: params.message
          }
        }
      "coins_selection" ->S
        %{
          recipient: %{
            id: params.psid
          },
          messaging_type: "RESPONSE",
          message: %{
            text: "List of coins requested",
            quick_replies: params.quick_replies
          }
        }
      "new_session_search_selection" ->
        %{
          recipient: %{
            id: params.psid
          },
          message: %{
            attachment: %{
              type: "template",
              payload: %{
                template_type: "generic",
                elements: [
                  %{
                    title: params.title,
                    subtitle: params.subtitle,
                    buttons: [
                      %{
                        type: "postback",
                        title: "By ID",
                        payload: "id"
                      },
                      %{
                        type: "postback",
                        title: "By Coin Name",
                        payload: "coin_name"
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
    end
  end
end
