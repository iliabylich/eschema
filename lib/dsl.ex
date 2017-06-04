defmodule ESchema.DSL do
  import Kernel, except: [&&: 2, ||: 2, >: 2, ^: 2]

  defmacro __using__(_options) do
    quote do
      @rules []
      @customs []

      import Kernel, except: [&&: 2, ||: 2, >: 2]
      import ESchema.DSL

      @before_compile ESchema.DSL
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def rules,   do: @rules
      def customs, do: @customs

      def call(params) do
        ESchema.Validator.call(__MODULE__, params)
      end

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

  def none?,                                        do: {:predicate, :none?}
  def eql?(value),                                  do: {:predicate, :eql?, value}
  def empty?,                                       do: {:predicate, :empty?}
  def filled?,                                      do: {:predicate, :filled?}
  def gt?(value)            when is_number(value),  do: {:predicate, :gt?, value}
  def gteq?(value)          when is_number(value),  do: {:predicate, :gteq?, value}
  def lt?(value)            when is_number(value),  do: {:predicate, :lt?, value}
  def lteq?(value)          when is_number(value),  do: {:predicate, :lteq?, value}
  def max_size?(value)      when is_integer(value), do: {:predicate, :max_size?, value}
  def min_size?(value)      when is_integer(value), do: {:predicate, :min_size?, value}
  def size?(value)          when is_integer(value), do: {:predicate, :size_exactly?, value}
  def size?(%Range{} = value),                      do: {:predicate, :size_between?, value}
  def format?(value),                               do: {:predicate, :format?, value}
  def included_in?(value)   when is_list(value),    do: {:predicate, :included_in?, value}
  def excluded_from?(value) when is_list(value),    do: {:predicate, :excluded_from?, value}

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

  ## Nested schemas support

  defmacro schema?(schema) do
    quote do
      map?() > {:schema, unquote(schema)}
    end
  end

  ## Arrays

  defmacro each(do: block) do
    quote do
      list?() > {:each, unquote(block)}
    end
  end
end
