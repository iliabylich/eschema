defmodule ESchema.PredicateLogic do
  @moduledoc false

  ## Primitive type checks

  def atom?(value) when is_atom(value) and not(is_boolean(value)) and value != nil, do: true
  def atom?(_), do: false

  def float?(value),   do: is_float(value)
  def list?(value),    do: is_list(value)
  def binary?(value),  do: is_binary(value)
  def map?(value),     do: is_map(value)
  def boolean?(value), do: is_boolean(value)
  def integer?(value), do: is_integer(value)

  ## Predefined checks

  def none?(value), do: value == nil

  def eql?(value, cmp), do: value == cmp

  def empty?(value), do: value == "" or value == [] or value == %{}

  def filled?(value), do: not(none?(value) or empty?(value))

  def gt?(value, cmp) when is_number(value), do: value > cmp
  def gt?(value, _), do: raise "gt? can compare only numbers (got #{inspect(value)})"

  def gteq?(value, cmp) when is_number(value), do: value >= cmp
  def gteq?(value, _), do: raise "gteq? can compare only numbers (got #{inspect(value)})"

  def lt?(value, cmp) when is_number(value), do: value < cmp
  def lt?(value, _), do: raise "lt? can compare only numbers (got #{inspect(value)})"

  def lteq?(value, cmp) when is_number(value), do: value <= cmp
  def lteq?(value, _), do: raise "lteq? can compare only numbers (got #{inspect(value)})"

  def max_size?(value, size) when is_list(value) or is_binary(value), do: _length(value) <= size
  def max_size?(value, _), do: raise "max_size? is supported only by list and binary (got #{inspect(value)})"

  def min_size?(value, size) when is_list(value) or is_binary(value), do: _length(value) >= size
  def min_size?(value, _), do: raise "min_size? is supported only by list and binary (got #{inspect(value)})"

  def size_exactly?(value, size) when is_binary(value) or is_list(value), do: _length(value) == size
  def size_exactly?(value, _), do: raise "size? is supported only by list and binary (got #{inspect(value)})"

  def size_between?(value, range) when is_binary(value) or is_list(value), do: Enum.member?(range, _length(value))
  def size_between?(value, _), do: raise "size? is supported only by list and binary (got #{inspect(value)})"

  defp _length(string) when is_binary(string), do: String.length(string)
  defp _length(list)   when is_list(list),     do: length(list)

  def format?(value, regex) when is_binary(value), do: Regex.match?(regex, value)
  def format?(value, _), do: raise "format? is supported only by binary (got #{inspect(value)})"

  def included_in?(value, list), do: Enum.member?(list, value)

  def excluded_from?(value, list), do: not included_in?(value, list)

  def has_key?(map, key) do
    Map.has_key?(map, key) or Map.has_key?(map, Atom.to_string(key))
  end
end
