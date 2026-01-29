defmodule PearlWeb.ErrorHTMLTest do
  use PearlWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    html = render_to_string(PearlWeb.ErrorHTML, "404", "html", [])
    assert html =~ "404"
    assert html =~ "a página que procuras parece não existir"
  end

  test "renders 500.html" do
    html = render_to_string(PearlWeb.ErrorHTML, "500", "html", [])
    assert html =~ "500"
    assert html =~ "Sorry! Our monkeys gave up on working."
  end
end
