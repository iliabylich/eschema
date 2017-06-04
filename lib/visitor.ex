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

  def call({:traverse, key, rule}, params) do
    nested = Map.get(params, key) || Map.get(params, Atom.to_string(key))

    case call(rule, nested) do
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
      {:ok, _} ->
        case call(right, params) do
          {:ok, _} = result -> result
          errors -> errors
        end
      errors -> errors
    end
  end

  def call({:disjunction, _left, _right}, _params), do: raise "Not Implemented"

  def call({:implication, left, right}, params) do
    case call(left, params) do
      {:ok, _} ->
        case call(right, params) do
          {:ok, _} = result -> result
          errors -> errors
        end
      _ -> {:ok, %{}}
    end
  end

  def call({:exclusive_disjunction, _left, _right}, _params), do: raise "Not Implemented"

  ## Arrays support

  def call({:each, nested}, list) do
    list
    |> Enum.map(fn(item) -> call(nested, item) end)
    |> Enum.split_with(&_has_error?/1)
    |> _merge_lsit_output
  end

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
