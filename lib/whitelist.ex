defmodule ESchema.Whitelist do
  def call(traversed, params) do
    traversed
    |> Enum.map(fn(traversed_item) -> visit(traversed_item, params) end)
    |> Enum.reduce(%{}, fn(item, acc) -> Map.merge(acc, item) end)
  end

  defp visit([head | tail], params) when is_list(head) do
    Map.merge(visit(head, params), visit(tail, params))
  end

  defp visit([:traverse, key, nested], params) when is_atom(key) do
    value = if Map.has_key?(params, key) do
      Map.get(params, key)
    else
      Map.get(params, Atom.to_string(key))
    end

    if is_map(value) do
      %{key => visit(nested, value)}
    else
      %{key => value}
    end
  end

  defp visit([], _) do
    %{}
  end
end
