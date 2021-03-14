defmodule Web.Handlers.Root do
  @moduledoc false
  use Plug.Router
  alias Utils.Mime

  if Mix.env == :dev do
    plug Plug.Logger
  end

  plug :match
  plug :dispatch

  get "/" do
    conn
    |> put_resp_content_type(Mime.html())
    |> send_file(200, Web.Ui.StaticAssets.index())
  end

  match _ do
    IO.puts("*** ERROR ***: trying to access path #{inspect conn.request_path}")

    conn
    |> put_resp_content_type(Mime.plain_text())
    |> send_resp(404, "")
  end

end
