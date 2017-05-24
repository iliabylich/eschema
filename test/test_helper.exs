defmodule TestSchema do
  use Schema.DSL

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
  rule do: tuple?()

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
  rule do: format?(~r/\w+/)
  rule do: included_in?(9..10)
  rule do: excluded_from?(11..12)

  ## Traversing
  rule do: traverse :key, do: eql?("value")
end


IO.inspect TestSchema.rules
IO.inspect TestSchema.customs


ExUnit.start()
