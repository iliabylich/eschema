defmodule ESchema.PredicateLogic do

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

  def none?(value) when value == nil, do: true
  def none?(_), do: false

  def eql?(value, cmp) when value == cmp, do: true
  def eql?(_, _), do: false

  def empty?(value) when value == "" or value == [] or value == %{}, do: true
  def empty?(_), do: false

  def filled?(value) when not(value == nil or value == "" or value == [] or value == %{}), do: true
  def filled?(_), do: false

  def gt?(value, cmp) when is_number(value) and value >  cmp, do: true
  def gt?(value, cmp) when is_number(value) and value <= cmp, do: false
  def gt?(value, _), do: raise "gt? can compare only numbers (got #{inspect(value)})"

  def gteq?(value, cmp) when is_number(value) and value >= cmp, do: true
  def gteq?(value, cmp) when is_number(value) and value <  cmp, do: false
  def gteq?(value, _), do: raise "gteq? can compare only numbers (got #{inspect(value)})"

  def lt?(value, cmp) when is_number(value) and value <  cmp, do: true
  def lt?(value, cmp) when is_number(value) and value >= cmp, do: false
  def lt?(value, _), do: raise "lt? can compare only numbers (got #{inspect(value)})"

  def lteq?(value, cmp) when is_number(value) and value <= cmp, do: true
  def lteq?(value, cmp) when is_number(value) and value >  cmp, do: false
  def lteq?(value, _), do: raise "lteq? can compare only numbers (got #{inspect(value)})"

  def max_size?(value, size) when is_list(value), do: length(value) <= size
  def max_size?(value, size) when is_binary(value), do: String.length(value) <= size
  def max_size?(value, _), do: raise "max_size? is supported only by list and binary (got #{inspect(value)})"

  def min_size?(value, size) when is_list(value), do: length(value) >= size
  def min_size?(value, size) when is_binary(value), do: String.length(value) >= size
  def min_size?(value, _), do: raise "min_size? is supported only by list and binary (got #{inspect(value)})"


  def size?(value, size) when is_list(value)   and is_integer(size), do: length(value) == size
  def size?(value, size) when is_binary(value) and is_integer(size), do: String.length(value) == size
  def size?(value, %Range{} = size) when is_list(value),   do: Enum.member?(size, length(value))
  def size?(value, %Range{} = size) when is_binary(value), do: Enum.member?(size, String.length(value))
  def size?(value, _), do: raise "size? is supported only by list and binary (got #{inspect(value)})"

  def format?(value, regex) when is_binary(value), do: Regex.match?(regex, value)
  def format?(value, _), do: raise "format? is supported only by binary (got #{inspect(value)})"

  def included_in?(value, list), do: Enum.member?(list, value)

  def excluded_from?(value, list), do: not included_in?(value, list)
end
