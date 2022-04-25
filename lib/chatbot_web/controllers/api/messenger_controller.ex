defmodule ChatbotWeb.Api.MessengerController do
  use ChatbotWeb, :controller

  alias Chatbot.Context.Messenger

  require Logger

  @doc """
    %{
      "hub.mode" => "subscirbe",
      "hub.verify_token" => "verify_token",
      "hub.challenge" => "12345678912"
    }
  """
  def verify_token(conn, params) do
    Logger.info("[FB_MESSENGER_CALLBACK] Verify Token #{inspect(params)}")
    with {:ok, challenge} <- Messenger.validate(params) do
      Logger.info(challenge)
      conn
      |> put_status(200)
      |> json(challenge)
    else
      {:error, error} ->
        conn
        |> put_status(401)
        |> json(error)
        |> halt()
    end
  end

  @doc """
    %{
      "object" => "something",
      "entry" => "something"
    }
  """
  def chat_message(conn, params) do
    Logger.info("[FB_MESSENGER_CALLBACK] Incoming Message #{inspect(params)}")
    with {:ok, response} <- Messenger.handle_message(params) do
      Logger.info(response)
      conn
      |> put_status(200)
      |> json(response)
    else
      {:error, error} ->
        conn
        |> put_status(404)
        |> json(error)
        |> halt()
    end
  end
end
