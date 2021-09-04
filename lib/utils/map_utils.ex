defmodule Utils.Map do
  @moduledoc """
  Utilities for maps
  """

  @doc """
  Recursively make an atom keyed map from a string keyed one. Only keys
  that are strings are changed.

  ## Parameters
  - string_keyed: %{} with string keys

  ## Returns
  - %{} Same as string_keyed only with atom keys
  """
  def atom_keys(string_keyed) when is_map(string_keyed) do
    for {k, v} <- string_keyed, into: %{} do
      case {is_binary(k), is_map(v)} do
        {true, true} -> {String.to_atom(k), atom_keys(v)}
        {true, false} -> {String.to_atom(k), v}
        {false, true} -> {k, atom_keys(v)}
        {false, false} -> {k, v}
      end
    end
  end
end
