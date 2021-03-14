defmodule Web.AssetServer do
  @moduledoc false

  ##############################
  # API
  ##############################

  def web_root, do: "#{:code.priv_dir(:elixir_honey) |> Path.join("ui/build")}"
end
