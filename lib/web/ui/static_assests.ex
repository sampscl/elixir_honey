defmodule Web.Ui.StaticAssets do
  @moduledoc """
  Assets not dynamically generated O.o
  """
  alias Utils.Mime
  use Plug.Builder

  #plug Plug.Logger
  plug Plug.Static, at: "", from: {:elixir_honey, "priv/ui/build/static"}
  plug :not_found

  def not_found(conn, _opts) do
    conn
    |> put_resp_content_type(Mime.plain_text())
    |> send_resp(404, "")
  end

  def index, do: Web.AssetServer.web_root() |> Path.join("index.html")
  def favicon, do: Web.AssetServer.web_root() |> Path.join("favicon.ico")
  def asset_manifest, do: Web.AssetServer.web_root() |> Path.join("asset-manifest.json")
  def service_worker, do: Web.AssetServer.web_root() |> Path.join("service-worker.js")
  def manifest, do: Web.AssetServer.web_root() |> Path.join("manifest.json")

end
