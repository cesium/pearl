defmodule PearlWeb.PageController do
  use PearlWeb, :controller

  @palavra_secreta "miau"

  def check_palavra(conn, %{"palavra" => @palavra_secreta}) do
    redirect(conn, to: ~p"/gato")
  end

  def check_palavra(conn, _params) do
    redirect(conn, to: ~p"/")
  end

  def gato(conn, _params) do
    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, "priv/static/cat.html")
  end
end
