defmodule Chatbot.Service.FacebookMessenger.Session do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [],
      name: __MODULE__
    )
  end

  @impl true
  def init(task) do
    {:ok, [task]}
  end

  # API
  def get(psid) do
    GenServer.call(__MODULE__, {:get, psid})
  end

  def insert(psid, text, postback \\ nil) do
    GenServer.call(__MODULE__, {:insert, {text, psid, postback}})
  end

  def delete(psid) do
    GenServer.call(__MODULE__, {:delete, psid})
  end

  @impl true
  def handle_call({:get, psid}, _, state) do
    reply = get(psid)
    {:reply, reply, state}
  end

  def handle_call({:insert, {psid, text, postback}}, _, state) do
    reply = insert(psid, text, postback)
    {:reply, reply, state}
  end

  def handle_call({:delete, psid}, _, state) do
    reply = delete(psid)
    {:reply, reply, state}
  end
end
