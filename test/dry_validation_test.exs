defmodule DryValidationTest do
  use ExUnit.Case

  test "the truth" do
    assert TestSchema.rules == [
      {:traverse, :atom,          {:predicate, :atom?}},
      {:traverse, :float,         {:predicate, :float?}},
      {:traverse, :list,          {:predicate, :list?}},
      {:traverse, :binary,        {:predicate, :binary?}},
      {:traverse, :map,           {:predicate, :map?}},
      {:traverse, :boolean,       {:predicate, :boolean?}},
      {:traverse, :integer,       {:predicate, :integer?}},
      {:traverse, :tuple,         {:predicate, :tuple?}},

      {:traverse, :and,           {:conjunction, :left, :right}},
      {:traverse, :or,            {:disjunction, :left, :right}},
      {:traverse, :if,            {:implication, :left, :right}},
      {:traverse, :xor,           {:exclusive_disjunction, :left, :right}},

      {:traverse, :custom,        {:custom, :custom_predicate?}},

      {:traverse, :none,          {:predicate, :none?}},
      {:traverse, :eql,           {:predicate, :eql?, 1}},
      {:traverse, :empty,         {:predicate, :empty?}},
      {:traverse, :filled,        {:predicate, :filled?}},
      {:traverse, :gt,            {:predicate, :gt?, 2}},
      {:traverse, :gteq,          {:predicate, :gteq?, 3}},
      {:traverse, :lt,            {:predicate, :lt?, 4}},
      {:traverse, :lteq,          {:predicate, :lteq?, 5}},
      {:traverse, :max_size,      {:predicate, :max_size?, 6}},
      {:traverse, :min_size,      {:predicate, :min_size?, 7}},
      {:traverse, :size,          {:predicate, :size?, 8}},
      {:traverse, :format,        {:predicate, :format?, ~r/\w+/}},
      {:traverse, :included_in,   {:predicate, :included_in?, 9..10}},
      {:traverse, :excluded_from, {:predicate, :excluded_from?, 11..12}}
    ]
  end
end
