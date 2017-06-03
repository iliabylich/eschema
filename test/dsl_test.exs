defmodule ESchema.DSLTest do
  use ExUnit.Case

  defmodule NestedSchema do
  end

  defmodule TestSchema do
    use ESchema.DSL

    defmodule Custom do
      def custom_predicate?(value) do
        value == "email@example.com"
      end
    end

    custom Custom

    ## Type checks
    rule do: atom?()
    rule do: float?()
    rule do: list?()
    rule do: binary?()
    rule do: map?()
    rule do: boolean?()
    rule do: integer?()

    ## Boolean operations
    rule do: :left && :right
    rule do: :left || :right
    rule do: :left > :right
    rule do: :left ^^^ :right

    ## Custom assertions
    rule do: :custom_predicate?

    ## Predefined checks
    rule do: none?()
    rule do: eql?(1)
    rule do: empty?()
    rule do: filled?()
    rule do: gt?(2)
    rule do: gteq?(3)
    rule do: lt?(4)
    rule do: lteq?(5)
    rule do: max_size?(6)
    rule do: min_size?(7)
    rule do: size?(8)
    rule do: size?(9..10)
    rule do: format?(~r/\w+/)
    rule do: included_in?([11])
    rule do: excluded_from?([12])

    ## Traversing
    rule do: traverse :key, do: eql?("value")

    ## Defining rules
    rule do: binary?() > eql?("value")
    rule do: has_key?(:req) && traverse(:req, do: gt?(3)) # Equivalent to `required :req, do: gt?(3)
    rule do: has_key?(:opt) > traverse(:opt, do: gt?(4))  # Equivalent to `optional :opt, do: gt?(4)

    ## Builtin rules
    required :req, do: gt?(3)
    optional :opt, do: gt?(4)

    ## Nested schemas
    required :user, do: map?() > {:schema, NestedSchema}
    required :user, do: schema?(NestedSchema)

    ## Arrays
    required :user_ids, do: each do: integer?()
  end

  test "the truth" do
    assert TestSchema.rules == [
      {:rule, {:predicate, :atom?}},
      {:rule, {:predicate, :float?}},
      {:rule, {:predicate, :list?}},
      {:rule, {:predicate, :binary?}},
      {:rule, {:predicate, :map?}},
      {:rule, {:predicate, :boolean?}},
      {:rule, {:predicate, :integer?}},

      {:rule, {:conjunction, :left, :right}},
      {:rule, {:disjunction, :left, :right}},
      {:rule, {:implication, :left, :right}},
      {:rule, {:exclusive_disjunction, :left, :right}},

      {:rule, :custom_predicate?},

      {:rule, {:predicate, :none?}},
      {:rule, {:predicate, :eql?, 1}},
      {:rule, {:predicate, :empty?}},
      {:rule, {:predicate, :filled?}},
      {:rule, {:predicate, :gt?, 2}},
      {:rule, {:predicate, :gteq?, 3}},
      {:rule, {:predicate, :lt?, 4}},
      {:rule, {:predicate, :lteq?, 5}},
      {:rule, {:predicate, :max_size?, 6}},
      {:rule, {:predicate, :min_size?, 7}},
      {:rule, {:predicate, :size_exactly?, 8}},
      {:rule, {:predicate, :size_between?, (9..10)}},
      {:rule, {:predicate, :format?, ~r/\w+/}},
      {:rule, {:predicate, :included_in?, [11]}},
      {:rule, {:predicate, :excluded_from?, [12]}},

      {:rule, {:traverse, :key, {:predicate, :eql?, "value"}}},

      {:rule, {:implication, {:predicate, :binary?}, {:predicate, :eql?, "value"}}},
      {:rule, {:conjunction, {:predicate, :has_key?, :req}, {:traverse, :req, {:predicate, :gt?, 3}}}},
      {:rule, {:implication, {:predicate, :has_key?, :opt}, {:traverse, :opt, {:predicate, :gt?, 4}}}},

      {:rule, {:conjunction, {:predicate, :has_key?, :req}, {:traverse, :req, {:predicate, :gt?, 3}}}},
      {:rule, {:implication, {:predicate, :has_key?, :opt}, {:traverse, :opt, {:predicate, :gt?, 4}}}},

      {:rule, {:conjunction, {:predicate, :has_key?, :user}, {:traverse, :user, {:implication, {:predicate, :map?}, {:schema, NestedSchema}}}}},
      {:rule, {:conjunction, {:predicate, :has_key?, :user}, {:traverse, :user, {:implication, {:predicate, :map?}, {:schema, NestedSchema}}}}},

      {:rule, {:conjunction, {:predicate, :has_key?, :user_ids}, {:traverse, :user_ids, {:implication, {:predicate, :list?}, {:each, {:predicate, :integer?}}}}}}
    ]
  end
end
