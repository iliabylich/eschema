defmodule ESchema.VisitorTest do
  use ExUnit.Case

  alias ESchema.Visitor, as: V

  defmodule Plain do
    use ESchema.DSL

    required :name, do: binary?()
  end

  test "it handles simple rules for valid params" do
    params = %{"name" => "value"}
    assert V.call({:schema, Plain}, params) == {:ok, %{name: "value"}}
  end

  test "it handles simple rules for invalid params" do
    params = %{"name" => :not_a_binary}
    assert V.call({:schema, Plain}, params) == {:error, [[:key, :name, [:binary?]]]}
  end


  defmodule Composite do
    use ESchema.DSL

    required :password, do: binary?() && size?(8..10)
  end

  test "it handles composite rules for valid params" do
    params = %{"password" => "password"}
    assert V.call({:schema, Composite}, params) == {:ok, %{password: "password"}}
  end

  test "it handles composite rules for invalid params" do
    params = %{"password" => :not_a_binary}
    assert V.call({:schema, Composite}, params) == {:error, [[:key, :password, [:binary?]]]}

    params = %{"password" => "1234567"}
    assert V.call({:schema, Composite}, params) == {:error, [[:key, :password, [:size_between?, 8..10]]]}

    params = %{"password" => "1234567891011"}
    assert V.call({:schema, Composite}, params) == {:error, [[:key, :password, [:size_between?, 8..10]]]}
  end

  defmodule Nested do
    use ESchema.DSL

    required :nested, do: schema?(Plain)
  end

  test "it handles nested schemas for valid params" do
    params = %{"nested" => %{"name" => "value"}}
    assert V.call({:schema, Nested}, params) == {:ok, %{nested: %{name: "value"}}}
  end

  test "it handles nested schemas for invalid params" do
    params = %{"nested" => %{"name" => :not_a_binary}}
    assert V.call({:schema, Nested}, params) == {:error, [[:key, :nested, [[:key, :name, [:binary?]]]]]}
  end

  defmodule ArrayOfPredicates do
    use ESchema.DSL

    required :tags, do: each do: binary?()
  end

  test "it handles nested arrays of predicates for valid params" do
    params = %{"tags" => ["a", "b", "c"]}
    assert V.call({:schema, ArrayOfPredicates}, params) == {:ok, %{tags: ["a", "b", "c"]}}
  end

  test "it handles nested arrays of predicates for invalid params" do
    params = %{"tags" => ["a", :binary1, "c", 0]}
    assert V.call({:schema, ArrayOfPredicates}, params) == {:error, [[:key, :tags, [:array, [1, [:binary?]], [3, [:binary?]]]]]}
  end

  defmodule ArrayOfSchemas do
    use ESchema.DSL

    required :users, do: each do: schema?(Plain)
  end

  test "it handles nested arrays of schemas" do
    params = %{"users" => [%{"name" => "user1"}, %{"name" => "user2"}]}
    assert V.call({:schema, ArrayOfSchemas}, params) == {:ok, %{users: [%{name: "user1"}, %{name: "user2"}]}}
  end

  test "it handles nested arrays of schema for valid params" do
    params = %{
      "users" => [
        %{"name" => :not_a_binary1},
        %{"name" => "binary"},
        %{"name" => :not_a_binary2}
      ]
    }
    assert V.call({:schema, ArrayOfSchemas}, params) == {:error, [[:key, :users, [:array,
      [0, [[:key, :name, [:binary?]]]],
      [2, [[:key, :name, [:binary?]]]]
    ]]]}
  end
end
