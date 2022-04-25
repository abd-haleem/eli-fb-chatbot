defmodule Chatbot.Service.FacebookMessenger.Client do
  use HTTPoison.Base
  alias HTTPoison.Request

  @type resp :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}

  def request(method, path, body \\ "", headers \\ [], options \\ []) do
    base_url = "https://graph.facebook.com/v12.0/me/"

    url = base_url <> path <> "?access_token=" <> Application.get_env(:chatbot, :facebook_page_token)

    headers = [
      {"Content-type", "application/json"} | headers
    ]

    request(%Request{
      method: method,
      url: url,
      headers: headers,
      body: body,
      options: options
    })
  end

  def process_request_body(body) do
    case body do
      "" -> body
      _ -> body |> Jason.encode!
    end
  end

  def process_response_body(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> decoded
      _ -> body
    end
  end
end
