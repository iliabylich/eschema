defmodule Schema.DSL do
  import Kernel, except: [&&: 2, ||: 2, >: 2, ^: 2]

  defmacro __using__(_options) do
    quote do
      @rules []
      @customs []

      import Kernel, except: [&&: 2, ||: 2, >: 2]
      import Schema.DSL

      @before_compile Schema.DSL
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def rules,   do: @rules
      def customs, do: @customs

      # TODO: validate that all custom predicates are available
    end
  end

  defmacro custom(module) do
    quote do
      @customs @customs ++ [unquote(module)]
    end
  end

  ## High-level rules

  defmacro rule(do: block) do
    quote do
      rule = {:rule, unquote(block)}
      @rules @rules ++ [rule]
    end
  end

  ## Primitive type checks

  def atom?,    do: {:predicate, :atom?}
  def float?,   do: {:predicate, :float?}
  def list?,    do: {:predicate, :list?}
  def binary?,  do: {:predicate, :binary?}
  def map?,     do: {:predicate, :map?}
  def boolean?, do: {:predicate, :boolean?}
  def integer?, do: {:predicate, :integer?}
  def tuple?,   do: {:predicate, :tuple?}

  ## Boolean operators

  def left && right do
    {:conjunction, left, right}
  end

  def left || right do
    {:disjunction, left, right}
  end

  def left > right do
    {:implication, left, right}
  end

  def left ^^^ right do
    {:exclusive_disjunction, left, right}
  end

  ## Predefined checks

  def none?,                 do: {:predicate, :none?}
  def eql?(value),           do: {:predicate, :eql?, value}
  def empty?,                do: {:predicate, :empty?}
  def filled?,               do: {:predicate, :filled?}
  def gt?(value),            do: {:predicate, :gt?, value}
  def gteq?(value),          do: {:predicate, :gteq?, value}
  def lt?(value),            do: {:predicate, :lt?, value}
  def lteq?(value),          do: {:predicate, :lteq?, value}
  def max_size?(value),      do: {:predicate, :max_size?, value}
  def min_size?(value),      do: {:predicate, :min_size?, value}
  def size?(value),          do: {:predicate, :size?, value}
  def format?(value),        do: {:predicate, :format?, value}
  def included_in?(value),   do: {:predicate, :included_in?, value}
  def excluded_from?(value), do: {:predicate, :excluded_from?, value}

  ## Traversing

  defmacro traverse(path, do: block) do
    quote do
      {:traverse, unquote(path), unquote(block)}
    end
  end

  def has_key?(key) do
    {:predicate, :has_key?, key}
  end

  ## Builtin high-level rules

  defmacro required(key, do: block) do
    quote do
      rule do: has_key?(unquote(key)) && traverse(unquote(key), do: unquote(block))
    end
  end

  defmacro optional(key, do: block) do
    quote do
      rule do: has_key?(unquote(key)) > traverse(unquote(key), do: unquote(block))
    end
  end
end
