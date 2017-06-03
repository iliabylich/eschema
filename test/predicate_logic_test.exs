defmodule ESchema.PredicateLogicTest do
  use ExUnit.Case

  alias ESchema.PredicateLogic, as: P

  test "atom?(value)" do
    assert P.atom?(:a)
    refute P.atom?(1.0)
    refute P.atom?([])
    refute P.atom?("a")
    refute P.atom?(%{})
    refute P.atom?(true)
    refute P.atom?(false)
    refute P.atom?(1)
    refute P.atom?(nil)
  end

  test "float?(value)" do
    refute P.float?(:a)
    assert P.float?(1.0)
    refute P.float?([])
    refute P.float?("a")
    refute P.float?(%{})
    refute P.float?(true)
    refute P.atom?(false)
    refute P.float?(1)
    refute P.float?(nil)
  end

  test "list?(value)" do
    refute P.list?(:a)
    refute P.list?(1.0)
    assert P.list?([])
    refute P.list?("a")
    refute P.list?(%{})
    refute P.list?(true)
    refute P.atom?(false)
    refute P.list?(1)
    refute P.list?(nil)
  end

  test "binary?(value)" do
    refute P.binary?(:a)
    refute P.binary?(1.0)
    refute P.binary?([])
    assert P.binary?("a")
    refute P.binary?(%{})
    refute P.binary?(true)
    refute P.atom?(false)
    refute P.binary?(1)
    refute P.binary?(nil)
  end

  test "map?(value)" do
    refute P.map?(:a)
    refute P.map?(1.0)
    refute P.map?([])
    refute P.map?("a")
    assert P.map?(%{})
    refute P.map?(true)
    refute P.atom?(false)
    refute P.map?(1)
    refute P.map?(nil)
  end

  test "boolean?(value)" do
    refute P.boolean?(:a)
    refute P.boolean?(1.0)
    refute P.boolean?([])
    refute P.boolean?("a")
    refute P.boolean?(%{})
    assert P.boolean?(true)
    assert P.boolean?(false)
    refute P.boolean?(1)
    refute P.boolean?(nil)
  end

  test "integer?(value)" do
    refute P.integer?(:a)
    refute P.integer?(1.0)
    refute P.integer?([])
    refute P.integer?("a")
    refute P.integer?(%{})
    refute P.integer?(true)
    refute P.integer?(false)
    assert P.integer?(1)
    refute P.integer?(nil)
  end

  test "none?(value)" do
    refute P.none?(:a)
    refute P.none?(1.0)
    refute P.none?([])
    refute P.none?("a")
    refute P.none?(%{})
    refute P.none?(true)
    refute P.none?(false)
    refute P.none?(1)
    assert P.none?(nil)

    refute P.none?("")
    refute P.none?([])
    refute P.none?(%{})
  end

  test "eql?(value, cmp)" do
    assert P.eql?(:a, :a)
    assert P.eql?(1.0, 1.0)
    assert P.eql?([], [])
    assert P.eql?("a", "a")
    assert P.eql?(%{}, %{})
    assert P.eql?(true, true)
    assert P.eql?(false, false)
    assert P.eql?(1, 1)
    assert P.eql?({}, {})
    assert P.eql?(nil, nil)

    refute P.eql?(:a, :b)
    refute P.eql?(:a, ["b"])
  end

  test "empty?(value)" do
    assert P.empty?("")
    assert P.empty?([])
    assert P.empty?(%{})

    refute P.empty?(:a)
    refute P.empty?(0.0)
    refute P.empty?([0])
    refute P.empty?("0")
    refute P.empty?(%{"0" => "0"})
    refute P.empty?(true)
    refute P.empty?(false)
    refute P.empty?(1)
    refute P.empty?(nil)
  end

  test "filled?(value)" do
    assert P.filled?(:a)
    assert P.filled?(0.0)
    assert P.filled?([1])
    assert P.filled?("a")
    assert P.filled?(%{"a" => "b"})
    assert P.filled?(true)
    assert P.filled?(false)
    assert P.filled?(1)

    refute P.filled?(nil)
    refute P.filled?("")
    refute P.filled?([])
    refute P.filled?(%{})
  end

  test "gt?(value, cmp)" do
    assert P.gt?(10, 1)
    assert P.gt?(10, 1.0)
    assert P.gt?(10.0, 1)
    assert P.gt?(10.0, 1.0)

    refute P.gt?(1, 1)
    refute P.gt?(1, 1.0)
    refute P.gt?(1.0, 1)
    refute P.gt?(1.0, 1.0)

    refute P.gt?(1, 10)
    refute P.gt?(1, 10.0)
    refute P.gt?(1.0, 10)
    refute P.gt?(1.0, 10.0)

    assert_raise RuntimeError, "gt? can compare only numbers (got [])", fn ->
      P.gt?([], %{})
    end
  end

  test "gteq?(value, cmp)" do
    assert P.gteq?(10, 1)
    assert P.gteq?(10, 1.0)
    assert P.gteq?(10.0, 1)
    assert P.gteq?(10.0, 1.0)

    assert P.gteq?(1, 1)
    assert P.gteq?(1, 1.0)
    assert P.gteq?(1.0, 1)
    assert P.gteq?(1.0, 1.0)

    refute P.gteq?(1, 10)
    refute P.gteq?(1, 10.0)
    refute P.gteq?(1.0, 10)
    refute P.gteq?(1.0, 10.0)

    assert_raise RuntimeError, "gteq? can compare only numbers (got [])", fn ->
      P.gteq?([], %{})
    end
  end

  test "lt?(value, cmp)" do
    assert P.lt?(1, 10)
    assert P.lt?(1, 10.0)
    assert P.lt?(1.0, 10)
    assert P.lt?(1.0, 10.0)

    refute P.lt?(1, 1)
    refute P.lt?(1, 1.0)
    refute P.lt?(1.0, 1)
    refute P.lt?(1.0, 1.0)

    refute P.lt?(10, 1)
    refute P.lt?(10, 1.0)
    refute P.lt?(10.0, 1)
    refute P.lt?(10.0, 1.0)

    assert_raise RuntimeError, "lt? can compare only numbers (got [])", fn ->
      P.lt?([], %{})
    end
  end

  test "lteq?(value, cmp)" do
    assert P.lteq?(1, 10)
    assert P.lteq?(1, 10.0)
    assert P.lteq?(1.0, 10)
    assert P.lteq?(1.0, 10.0)

    assert P.lteq?(1, 1)
    assert P.lteq?(1, 1.0)
    assert P.lteq?(1.0, 1)
    assert P.lteq?(1.0, 1.0)

    refute P.lteq?(10, 1)
    refute P.lteq?(10, 1.0)
    refute P.lteq?(10.0, 1)
    refute P.lteq?(10.0, 1.0)

    assert_raise RuntimeError, "lteq? can compare only numbers (got [])", fn ->
      P.lteq?([], %{})
    end
  end

  test "max_size?(value, size)" do
    refute P.max_size?("123", 2)
    assert P.max_size?("123", 3)
    assert P.max_size?("123", 4)

    refute P.max_size?([1, 2, 3], 2)
    assert P.max_size?([1, 2, 3], 3)
    assert P.max_size?([1, 2, 3], 4)

    assert_raise RuntimeError, "max_size? is supported only by list and binary (got %{})", fn ->
      P.max_size?(%{}, 1)
    end
  end

  test "min_size?(value, size)" do
    assert P.min_size?("123", 2)
    assert P.min_size?("123", 3)
    refute P.min_size?("123", 4)

    assert P.min_size?([1, 2, 3], 2)
    assert P.min_size?([1, 2, 3], 3)
    refute P.min_size?([1, 2, 3], 4)

    assert_raise RuntimeError, "min_size? is supported only by list and binary (got %{})", fn ->
      P.min_size?(%{}, 1)
    end
  end

  test "size_exactly?(value, size)" do
    refute P.size_exactly?("123", 2)
    assert P.size_exactly?("123", 3)
    refute P.size_exactly?("123", 4)

    refute P.size_exactly?([1, 2, 3], 2)
    assert P.size_exactly?([1, 2, 3], 3)
    refute P.size_exactly?([1, 2, 3], 4)

    assert_raise RuntimeError, "size? is supported only by list and binary (got %{})", fn ->
      P.size_exactly?(%{}, 1)
    end
  end

  test "size_between?(value, size)" do
    refute P.size_between?("123", 0..2)
    assert P.size_between?("123", 2..4)
    refute P.size_between?("123", 4..5)

    refute P.size_between?([1, 2, 3], 0..2)
    assert P.size_between?([1, 2, 3], 2..4)
    refute P.size_between?([1, 2, 3], 4..5)

    assert_raise RuntimeError, "size? is supported only by list and binary (got %{})", fn ->
      P.size_between?(%{}, 0..2)
    end
  end

  test "format?(value, regex)" do
    assert P.format?("string", ~r/\A\w+\z/)
    refute P.format?("!@$%%^", ~r/\A\w+\z/)

    assert_raise RuntimeError, "format? is supported only by binary (got [])", fn ->
      P.format?([], ~r//)
    end
  end

  test "included_in?(value, list)" do
    assert P.included_in?(1, [1, 2, 3])
    refute P.included_in?(4, [1, 2, 3])
  end

  test "excluded_from?(value, list)" do
    assert P.excluded_from?(4, [1, 2, 3])
    refute P.excluded_from?(1, [1, 2, 3])
  end
end
