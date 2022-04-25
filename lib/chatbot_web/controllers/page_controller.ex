defmodule ChatbotWeb.PageController do
  use ChatbotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
