defmodule ESchema.ValidatorTest do
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
    # optional :profile, do: schema?(ProfileSchema)
    # optional :tags, do: each do: binary?()
    # optional :friends, do: each do: schema?(FriendSchema)
  end

  use ExUnit.Case

  test "it accepts valid params and converts binary keys to atoms" do
    params = %{"email" => "email@email.com", "password" => "password", "profile" => %{"name" => "Name", "age" => 35}}
    assert ESchema.Validator.call(UserSchema, params) == {:ok, %{email: "email@email.com", password: "password"}}
  end

  # test "it returns {:error, errors} when params are invalid" do
  #   params = %{"email" => "not-an-email", "password" => "short"}
  #   assert Schema.Validator.call(UserSchema, params) == {:error, [[:email, :invalid_format], [:password, :too_short]]}
  # end
end
