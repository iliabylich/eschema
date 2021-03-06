defmodule ESchema.DSL do
  @moduledoc """
  ESchema.DSL provides a DSL to define your own schemas.

  ## Examples

    defmodule UserSchema do
      use ESchema.DSL

      required(:username), do: binary?() && max_length?(10)
      optional(:age), do: integer?() && gteq?(18)
    end

    iex> UserSchema.call(%{"username" => "john1985", "age" => 25})
    {:ok, %{username: "john1985", age: 25}}
  """

  alias ESchema.Validator

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
        Validator.call(__MODULE__, params)
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

  def none? do
    {:predicate, :none?}
  end

  def eql?(value) do
    {:predicate, :eql?, value}
  end

  def empty? do
    {:predicate, :empty?}
  end

  def filled? do
    {:predicate, :filled?}
  end

  def gt?(value) when is_number(value) do
    {:predicate, :gt?, value}
  end

  def gteq?(value) when is_number(value) do
    {:predicate, :gteq?, value}
  end

  def lt?(value) when is_number(value) do
    {:predicate, :lt?, value}
  end

  def lteq?(value) when is_number(value) do
    {:predicate, :lteq?, value}
  end

  def max_size?(value) when is_integer(value) do
    {:predicate, :max_size?, value}
  end

  def min_size?(value) when is_integer(value) do
    {:predicate, :min_size?, value}
  end

  def size?(value) when is_integer(value) do
    {:predicate, :size_exactly?, value}
  end

  def size?(%Range{} = value) do
    {:predicate, :size_between?, value}
  end

  def format?(value) do
    {:predicate, :format?, value}
  end

  def included_in?(value) when is_list(value) do
    {:predicate, :included_in?, value}
  end

  def excluded_from?(value) when is_list(value) do
    {:predicate, :excluded_from?, value}
  end

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
      rule do
        has_key?(unquote(key)) && traverse(unquote(key), do: unquote(block))
      end
    end
  end

  defmacro optional(key, do: block) do
    quote do
      rule do
        has_key?(unquote(key)) > traverse(unquote(key), do: unquote(block))
      end
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
