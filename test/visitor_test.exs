defmodule ESchema.VisitorTest do
  use ExUnit.Case

  alias ESchema.Visitor, as: V

  defmodule Plain do
    use ESchema.DSL

    required :name, do: binary?()
  end

  test "it handles simple rules" do
    params = %{"name" => "value"}
    assert V.call({:schema, Plain}, params) == {:ok, %{name: "value"}}
  end

  defmodule Composite do
    use ESchema.DSL

    required :password, do: binary?() && size?(8..10)
  end

  test "it handles composite rules" do
    params = %{"password" => "password"}
    assert V.call({:schema, Composite}, params) == {:ok, %{password: "password"}}
  end

  defmodule Nested do
    use ESchema.DSL

    required :nested, do: schema?(Plain)
  end

  test "it handles nested schemas" do
    params = %{"nested" => %{"name" => "value"}}
    assert V.call({:schema, Nested}, params) == {:ok, %{nested: %{name: "value"}}}
  end

  defmodule ArrayOfPredicates do
    use ESchema.DSL

    required :tags, do: each do: binary?()
  end

  test "it handles nested arrays of predicates" do
    params = %{"tags" => ["a", "b", "c"]}
    assert V.call({:schema, ArrayOfPredicates}, params) == {:ok, %{tags: ["a", "b", "c"]}}
  end

  defmodule ArrayOfSchemas do
    use ESchema.DSL

    required :users, do: each do: schema?(Plain)
  end

  test "it handles nested arrays of schemas" do
    params = %{"users" => [%{"name" => "user1"}, %{"name" => "user2"}]}
    assert V.call({:schema, ArrayOfSchemas}, params) == {:ok, %{users: [%{name: "user1"}, %{name: "user2"}]}}
  end
end
