defmodule ESchema.Visitor do
  ## Schema handling

  def call({:schema, schema}, params) do
    schema.rules
    |> Enum.map(fn(rule) -> call(rule, params) end)
    |> Enum.split_with(&_has_error?/1)
    |> _merge_schema_output
  end

  ## High-level rules

  def call({:rule, rule}, params) do
    call(rule, params)
  end

  ## Traversing

  def call({:predicate, :has_key?, key}, params) do
    {has_key, value} = cond do
      Map.has_key?(params, key)                 -> {true, Map.get(params, key)}
      Map.has_key?(params, Atom.to_string(key)) -> {true, Map.get(params, Atom.to_string(key))}
      true -> {false, nil}
    end

    if has_key do
      {:ok, value}
    else
      {:errors, [:has_key?, key]}
    end
  end

  def call({:traverse, key, nested_rule}, params) do
    nested_params = Map.get(params, key)
    nested_params = if nested_params == nil, do: Map.get(params, Atom.to_string(key))

    case call(nested_rule, nested_params) do
      {:ok, sanitized} ->
        {:ok, %{key => sanitized}}
      errors -> errors
    end
  end

  ## Predicates

  def call({:predicate, unary_predicate}, value) do
    if apply(ESchema.PredicateLogic, unary_predicate, [value]) do
      {:ok, value}
    else
      {:errors, [unary_predicate]}
    end
  end

  def call({:predicate, binary_predicate, arg}, value) do
    if apply(ESchema.PredicateLogic, binary_predicate, [value, arg]) do
      {:ok, value}
    else
      {:errors, [binary_predicate, arg]}
    end
  end

  ## Boolean operators

  def call({:conjunction, left, right}, params) do
    case call(left, params) do
      {:ok, sanitized_left} ->
        case call(right, params) do
          {:ok, sanitized_right} = result -> result
          errors -> errors
        end
      errors -> errors
    end
  end

  def call({:disjunction, _left, _right}, _params), do: raise "Not Implemented"

  def call({:implication, left, right}, params) do
    case call(left, params) do
      {:ok, sanitized_left} ->
        case call(right, params) do
          {:ok, sanitized_right} = result -> result
          errors -> errors
        end
      errors -> {:ok, %{}}
    end
  end

  def call({:exclusive_disjunction, _left, _right}, _params), do: raise "Not Implemented"

  ## Nested Schemas

  defp _has_error?({:ok, _}), do: false
  defp _has_error?({:errors, _}), do: true

  def _merge_schema_output({errors, outputs}) do
    errors = Enum.reduce(errors, [], fn({:errors, item}, acc) -> [item] ++ acc end)

    if errors == [] do
      output = Enum.reduce(outputs, %{}, fn({:ok, item}, acc) -> Map.merge(acc, item) end)
      {:ok, output}
    else
      {:errors, errors}
    end
  end

  ## Arrays support

  def call({:each, nested}, list) do
    list
    |> Enum.map(fn(item) -> call(nested, item) end)
    |> Enum.split_with(&_has_error?/1)
    |> _merge_lsit_output
  end

  def _merge_lsit_output({errors, outputs}) do
    errors = Enum.reduce(errors, [], fn({:errors, item}, acc) -> [item] ++ acc end)

    if errors == [] do
      output = Enum.reduce(outputs, [], fn({:ok, item}, acc) -> acc ++ [item] end)
      {:ok, output}
    else
      {:errors, errors}
    end
  end
end
