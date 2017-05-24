defmodule DryValidationTest do
  use ExUnit.Case

  test "the truth" do
    assert TestSchema.rules == [
      {:traverse, :int,    {:predicate, :int?}},
      {:traverse, :str,    {:predicate, :str?}},

      {:traverse, :and,    {:conjunction, :left, :right}},
      {:traverse, :or,     {:disjunction, :left, :right}},
      {:traverse, :if,     {:implication, :left, :right}},
      {:traverse, :xor,    {:exclusive_disjunction, :left, :right}},

      {:traverse, :custom, {:custom, :custom_predicate?}},

      {:traverse, :none,   {:predicate, :none?}},
      {:traverse, :eql,    {:predicate, :eql?, 5}}
    ]
  end
end
