defmodule Chatbot.Context.Messenger do
  alias Chatbot.Service.FacebookMessenger.Session

  def validate(params),
    do: do_validate(params)

  def handle_message(params),
    do: do_handle_message(params)

  defp do_validate(params) do
    with true <- params["hub.mode"] == "subscribe",
        true <- params["hub.verify_token"] == Application.get_env(:chatbot, :facebook_verify_token) do
      {:ok, params["hub.challenge"]}
    else
      _ -> {:error, %{status: 401, error: "unauthorized"}}
    end
  end

  defp do_handle_message(params) do
    case params.object do
      "page" ->
        response = do_response(params.entry)
        GenServer.start_link(Chatbot.Service.FacebookMessenger.Worker, response)
        {:ok, "EVENT_RECEIVED"}
      _ ->
        {:error, %{status: 404, error: "not found"}}
    end
  end

  defp do_response([entry]) do
    [messaging] = entry["messaging"]
    psid = messaging["sender"]["id"]

    case {Session.get(psid), messaging["postback"] != nil, messaging["message"]["quick_reply"] != nil} do
      {{_, _}, true, false} ->
        %{
          psid: psid,
          type: nil,
          text: messaging["postback"]["payload"]
        }
      {{:ok, chat_data}, false, false} ->
        type = if chat_data.postback, do: chat_data.text, else: nil

        %{
          psid: psid,
          type: type,
          text: messaging["message"]["text"]
        }
      {{:ok, _}, false, true} ->
        %{
          psid: psid,
          type: "show_results",
          text: messaging["message"]["quick_reply"]["payload"]
        }
      {{:error, _}, _, _} ->
        %{
          psid: psid,
          type: nil,
          text: messaging["message"]["text"]
        }
    end
  end
end
