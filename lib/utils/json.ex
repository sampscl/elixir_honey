defmodule Utils.Json do
  @moduledoc """
  Utils supporting JSON
  """
  def encode!(term) do
    {:ok, res} = encode(term)
    res
  end
  def encode(term) do
    term |> prepare |> Poison.encode
  end

  def decode!(json) do
    json |> Poison.decode!
  end

  def prepare(%{__struct__: module} = map) do
    map
    |> Map.delete(:__struct__)
    |> Map.put(:__struct, module)
    |> struct_prepare(module)
    |> prepare
  end
  def prepare(map) when is_map(map) do
    map
    |> Map.keys()
    |> Enum.filter(
      fn(key) ->
        !match?(%{__struct__: Ecto.Association.NotLoaded}, Map.get(map, key))
      end)
    |> Enum.map(
      fn(key) ->
        {key_prepare(key), prepare(Map.get(map, key))}
      end)
    |> Enum.into(%{})
  end
  def prepare([]), do: []
  def prepare(elements) when is_list(elements) do
    case Keyword.keyword?(elements) do
      true -> elements |> Enum.into(%{}) |> prepare
      false -> for element <- elements, do: prepare(element)
    end
  end
  def prepare(tuple) when is_tuple(tuple) do
    tuple
    |> Tuple.to_list
    |> prepare
  end
  def prepare(pid) when is_pid(pid) do
    prepare(String.slice(inspect(pid), 4..-1))
  end
  def prepare(fun) when is_function(fun), do: prepare(inspect(fun))

  def prepare(str) when is_bitstring(str) do
    if String.printable?(str) do
      str
    else
      "0x" <> Hexate.encode(str)
    end
  end
  def prepare(other), do: other

  def key_prepare(term) when is_integer(term) do
    key_prepare(Integer.to_string(term))
  end
  def key_prepare(term) do
    term
    |> prepare()
    |> do_key_prepare()
  end

  def do_key_prepare(t) when is_atom(t) or
                             is_bitstring(t) or
                             is_number(t), do: t
  def do_key_prepare(term) do
    inspect term
  end

  # this method is an opportunity to custom process individual structs
  def struct_prepare(other, DateTime), do: Timex.format!(other, "{ISO:Extended:Z}")
  def struct_prepare(other, NaiveDateTime), do: Timex.format!(other, "{ISO:Extended:Z}")
  def struct_prepare(other, _other_module), do: other

end
