defmodule ChatbotWeb.Api.MessengerControllerTest do
  use ChatbotWeb.ConnCase

  test "verifying facebook token", %{conn: conn} do
    Application.put_env(:chatbot, :facebook_verify_token, "chatbot")

    params = %{
      "hub.mode" => "subscribe",
      "hub.verify_token" => "chatbot",
      "hub.challenge" => "1234567890"
    }

    response =
      conn
      |> get("/api/messenger", params)
      |> json_response(200)

    assert response == params["hub.challenge"]
  end

  test "handle incoming message", %{conn: conn} do
    params = %{
      "entry" => [
        %{
          "id" => "123456789012345",
          "messaging" => [
            %{
              "message" => %{
                "mid" => "m_wLW6zdBJnV13gLX2Rpg7HLi57_7Ug_loTQg-sMWgp3BfrAAmwasEzxqg44MElWWo5gfhZhuDddp6B8zTvDZRHQ",
                "text" => "Hello"
              },
              "recipient" => %{
                "id" => "123456789012345"
              },
              "sender" => %{
                "id" => "111112222233333"
              },
              "timestamp" => 1855951101933
            }
          ],
          "time" => 1855951102587
        }
      ],
      object: "page"
    }

  response =
    conn
    |> post("/api/messenger", params)
    |> json_response(200)

  assert response == "EVENT_RECEIVED"
  end
end
