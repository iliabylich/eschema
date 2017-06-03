defmodule ESchema.Validator do
  def call(schema, params) do
    visit({:schema, schema}, params)
    |> to_result(params)
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

  ## Predicates

  defp visit({:predicate, unary_predicate}, value) do
    errors = if apply(ESchema.PredicateLogic, unary_predicate, [value]) do
      []
    else
      [[unary_predicate]]
    end

    %{traversed: [], errors: errors}
  end

  defp visit({:predicate, binary_predicate, arg}, value) do
    errors = if apply(ESchema.PredicateLogic, binary_predicate, [value, arg]) do
      []
    else
      [[binary_predicate]]
    end

    %{traversed: [], errors: errors}
  end

  ## Boolean operators

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

  defp visit({:disjunction, _left, _right}, _params), do: raise "Not Implemented"

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

  defp visit({:exclusive_disjunction, _left, _right}, _params), do: raise "Not Implemented"

  ## Nested schemas support

  defp visit({:schema, schema}, params) do
    schema.rules
    |> Enum.map(fn({:rule, rule}) -> visit(rule, params) end)
    |> merge
  end

  defp merge(items) do
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

  defp to_result(%{errors: errors, traversed: _traversed}, _params) do
    raise "Don't know how to collect errors: #{inspect(errors)}"
  end
end
