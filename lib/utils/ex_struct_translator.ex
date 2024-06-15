defmodule ExStructTranslator do
    @moduledoc """
      A Translator of Structs in Elixir.
    """
    @doc """
      translate a map with string-key to atom-key recursively.
    """
    def to_atom_struct(list) when is_list(list) do
      Enum.map(list, fn ele ->
        to_atom_struct(ele)
      end)
    end

    def to_atom_struct(struct) when is_map(struct) do
      for {key, val} <- struct, into: %{}, do: {translate_key(key), to_atom_struct(val)}
    end

    def to_atom_struct(else_ele) do
      else_ele
    end

    defp translate_key(key) when is_atom(key), do: key
    defp translate_key(key), do: String.to_atom(key)

    @doc """
      struct => map
    """
    def struct_to_map(struct) do
      struct
      |> Map.from_struct()
      |> Map.delete(:__meta__)
      |> Enum.reject(fn {_, v} ->
        case is_assoc_loaded_type?(v) do
          true ->
            not Ecto.assoc_loaded?(v)

          false ->
            false
        end
      end)
      |> Enum.into(%{})
    end

    def is_assoc_loaded_type?(%Ecto.Association.NotLoaded{}), do: true
    def is_assoc_loaded_type?(_), do: false

    @doc """
      map => struct
    """
    @spec map_to_struct(atom(), map()) :: Struct.t()
    def map_to_struct(kind, attrs) do
      struct = struct(kind)

      Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
        case Map.fetch(attrs, Atom.to_string(k)) do
          {:ok, v} ->
            %{acc | k => v}

          :error ->
            case Map.fetch(attrs, k) do
              {:ok, v} -> %{acc | k => v}
              :error -> acc
            end
        end
      end)
    end

    @doc """
      map => str
    """
    def map_to_str(map) when is_nil(map), do: nil
    def map_to_str(map), do: Poison.encode!(map)

    @doc """
      str => atom map
    """
    def str_to_atom_map(str) do
      str
      |> str_to_map()
      |> to_atom_struct()
    end

    @doc """
      str => map
    """
    def str_to_map(str) do
      str
      |> String.replace("\'", "\"")
      |> Poison.decode!()
    end
  end