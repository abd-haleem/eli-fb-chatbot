defmodule Chatbot.Service.FacebookMessenger.Worker do
  use GenServer

  Chatbot.Service.FacebookMessenger.Message

  @impl false
  def start_link(params) do
    GenServer.start_link(__MODULE__, params)
  end

  @impl true
  def init(params) do
    Process.send_after(self(), {:send_message, params}, 10)
    {:ok, []}
  end

  @impl true
  def handle_info({:send_message, params}, state) do
    generated_response = Chatbot.Service.FacebookMessenger.Chatbot.handle_message(params.text, params.psid, params.type)
    Chatbot.Service.FacebookMessenger.Message.send_message(generated_response)
    {:stop, :normal, state}
  end
end
