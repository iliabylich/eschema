defmodule DryValidationTest do
  use ExUnit.Case

  test "the truth" do
    assert TestSchema.rules == [
      {:rule, {:predicate, :atom?}},
      {:rule, {:predicate, :float?}},
      {:rule, {:predicate, :list?}},
      {:rule, {:predicate, :binary?}},
      {:rule, {:predicate, :map?}},
      {:rule, {:predicate, :boolean?}},
      {:rule, {:predicate, :integer?}},
      {:rule, {:predicate, :tuple?}},

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
      {:rule, {:predicate, :size?, 8}},
      {:rule, {:predicate, :format?, ~r/\w+/}},
      {:rule, {:predicate, :included_in?, 9..10}},
      {:rule, {:predicate, :excluded_from?, 11..12}},

      {:rule, {:traverse, :key, {:predicate, :eql?, "value"}}},

      {:rule, {:implication, {:predicate, :binary?}, {:predicate, :eql?, "value"}}},
      {:rule, {:conjunction, {:predicate, :has_key?, :req}, {:traverse, :req, {:predicate, :gt?, 3}}}},
      {:rule, {:implication, {:predicate, :has_key?, :opt}, {:traverse, :opt, {:predicate, :gt?, 4}}}},

      {:rule, {:conjunction, {:predicate, :has_key?, :req}, {:traverse, :req, {:predicate, :gt?, 3}}}},
      {:rule, {:implication, {:predicate, :has_key?, :opt}, {:traverse, :opt, {:predicate, :gt?, 4}}}},
    ]
  end
end
