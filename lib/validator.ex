defmodule ESchema.Validator do
  def call(schema, params) do
    schema.rules
    |> Enum.map(fn({:rule, rule}) -> visit(rule, params) end)
    |> merge_result
    |> to_result(params)
  end

  defp visit({:conjunction, left, right}, params) do
    %{traversed: traversed_by_left, errors: errors_by_left} = visit(left, params)

    if errors_by_left == [] do
      %{traversed: traversed_by_right, errors: errors_by_right} = visit(right, params)

      traversed = traversed_by_left ++ traversed_by_right
      errors = errors_by_right
      %{traversed: traversed, errors: errors}
    else
      %{traversed: traversed_by_left, errors: errors_by_left}
    end
  end

  defp visit({:implication, left, right}, params) do
    %{traversed: traversed_by_left, errors: errors_by_left} = visit(left, params)

    if errors_by_left == [] do
      %{traversed: traversed_by_right, errors: errors_by_right} = visit(right, params)

      traversed = traversed_by_left ++ traversed_by_right
      errors = errors_by_right
      %{traversed: traversed, errors: errors}
    else
      %{traversed: traversed_by_left, errors: []}
    end
  end

  defp visit({:predicate, :has_key?, key}, params) do
    has_key = Map.has_key?(params, key) or Map.has_key?(params, Atom.to_string(key))

    if has_key do
      %{traversed: [], errors: []}
    else
      %{traversed: [], errors: [[:has_key?, key]]}
    end
  end

  defp visit({:traverse, key, rule}, params) do
    value = if Map.has_key?(params, key) do
      Map.get(params, key)
    else
      Map.get(params, Atom.to_string(key))
    end

    %{traversed: traversed, errors: errors} = visit(rule, value)
    traversed = [key, traversed]
    %{traversed: traversed, errors: errors}
  end

  defp visit({:predicate, :binary?}, value) do
    if is_binary(value) do
      %{traversed: [], errors: []}
    else
      %{traversed: [], errors: [[:binary?, value]]}
    end
  end

  defp visit({:predicate, :format?, regex}, value) do
    if Regex.match?(regex, value) do
      %{traversed: [], errors: []}
    else
      %{traversed: [], errors: [[:format?, regex, value]]}
    end
  end

  defp visit({:predicate, :size?, size}, value) when is_integer(size) do
    if _length_of(value) == size do
      %{traversed: [], errors: []}
    else
      %{traversed: [], errors: [[:size?, size, value]]}
    end
  end

  defp visit({:predicate, :size?, range}, value) do
    if Enum.member?(range, _length_of(value)) do
      %{traversed: [], errors: []}
    else
      %{traversed: [], errors: [[:size?, range, value]]}
    end
  end

  defp _length_of(value) when is_list(value), do: length(value)
  defp _length_of(value) when is_binary(value), do: String.length(value)

  defp merge_result(items) do
    Enum.reduce(items, %{traversed: [], errors: []}, fn(item, result) ->
      %{traversed: item_traversed, errors: item_errors} = item
      %{traversed: result_traversed, errors: result_errors} = result

      %{traversed: [item_traversed] ++ result_traversed, errors: item_errors ++ result_errors}
    end)
  end

  defp to_result(%{errors: [], traversed: traversed}, params) do
    params = ESchema.Whitelist.call(traversed, params)
    {:ok, params}
  end

  defp to_result(%{errors: _errors, traversed: _traversed}, _params) do
    raise "TBD"
  end
end
