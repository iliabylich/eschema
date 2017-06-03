defmodule ESchema.ValidatorTest do
  alias ESchema.Validator

  defmodule ProfileSchema do
    use ESchema.DSL

    required :name, do: binary?() && max_size?(20)
    required :age, do: integer?() && gt?(18) && lt?(100)
  end

  # defmodule FriendSchema do
  #   use Schema.DSL

  #   required :name, do: binary?()
  # end

  defmodule UserSchema do
    use ESchema.DSL

    required :email, do: binary?() && format?(~r/\A\w+@\w+\.com/)
    required :password, do: binary?() && size?(8..10)
    optional :profile, do: schema?(ProfileSchema)
    optional :tags, do: each do: binary?()
    # optional :friends, do: each do: schema?(FriendSchema)
  end

  use ExUnit.Case

  test "plain valid params" do
    params = %{"email" => "email@email.com", "password" => "password"}
    assert Validator.call(UserSchema, params) == {:ok, %{email: "email@email.com", password: "password"}}
  end

  test "nested valid params" do
    params = %{"email" => "email@email.com", "password" => "password", "profile" => %{"name" => "Name", "age" => 35}}
    assert Validator.call(UserSchema, params) == {:ok, %{email: "email@email.com", password: "password", profile: %{name: "Name", age: 35}}}
  end

  test "nested arrays of primitives" do
    params = %{"email" => "email@email.com", "password" => "password", "tags" => ["a", "b"]}
    assert Validator.call(UserSchema, params) == {:ok, %{email: "email@email.com", password: "password", tags: ["a", "b"]}}
  end
end
