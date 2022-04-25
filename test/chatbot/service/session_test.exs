defmodule Chatbot.Service.FacebookMessenger.SessionTest do
  use ExUnit.Case, async: false

  alias Chatbot.Service.FacebookMessenger.Session

  test "get session" do
    psid = "12345678901"
    text = "Hello"

    insert_respons = Session.insert(psid, text)
    response = Session.get(psid)

    assert insert_response == {:ok, :success}

    assert {:ok, _} = response

    {_, data} = response

    assert data.text == text
    assert data.postback == nil
  end

  test "insert session" do
    psid = "12345678901"
    text = "Hello"

    insert_response = Session.insert(psid, text)

    assert insert_response == {:ok, :success}
  end

  test "delete session" do
    psid = "12345678901"
    text = "Hello"

    Session.insert(psid, text)

    response = Session.delete(psid)

    assert response == {:ok, :success}
  end
end
