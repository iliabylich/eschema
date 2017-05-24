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

  defmacro key(path, do: block) do
    quote do
      rule = traverse(unquote(path), unquote(block))
      @rules @rules ++ [rule]
    end
  end

  defmacro custom(module) do
    quote do
      @customs @customs ++ [unquote(module)]
    end
  end

  def traverse(path, rule) when is_tuple(rule) do
    {:traverse, path, rule}
  end

  def traverse(path, custom_rule) when is_atom(custom_rule) do
    {:traverse, path, {:custom, custom_rule}}
  end

  def int? do
    {:predicate, :int?}
  end

  def lt?(value) do
    {:predicate, :lt?, value}
  end

  def filled? do
    {:predicate, :filled?}
  end

  def str? do
    {:predicate, :str?}
  end

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

  def none? do
    {:predicate, :none?}
  end

  def eql?(value) do
    {:predicate, :eql?, value}
  end
end
