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
    cat_html_path =
      :pearl
      |> :code.priv_dir()
      |> to_string()
      |> Path.join("static/cat.html")

    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, cat_html_path)
  end
end
