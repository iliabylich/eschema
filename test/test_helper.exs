defmodule TestSchema do
  use Schema.DSL

  defmodule Custom do
    def custom_predicate?(value) do
      value == "email@example.com"
    end
  end

  custom Custom

  ## Type checks
  key :atom,      do: atom?()
  key :float,     do: float?()
  key :list,      do: list?()
  key :binary,    do: binary?()
  key :map,       do: map?()
  key :boolean,   do: boolean?()
  key :integer,   do: integer?()
  key :tuple,     do: tuple?()

  ## Boolean operations
  key :and, do: :left && :right
  key :or,  do: :left || :right
  key :if,  do: :left > :right
  key :xor, do: :left ^^^ :right

  ## Custom assertions
  key :custom,    do: :custom_predicate?

  ## Predefined checks
  key :none,          do: none?()
  key :eql,           do: eql?(1)
  key :empty,         do: empty?()
  key :filled,        do: filled?()
  key :gt,            do: gt?(2)
  key :gteq,          do: gteq?(3)
  key :lt,            do: lt?(4)
  key :lteq,          do: lteq?(5)
  key :max_size,      do: max_size?(6)
  key :min_size,      do: min_size?(7)
  key :size,          do: size?(8)
  key :format,        do: format?(~r/\w+/)
  key :included_in,   do: included_in?(9..10)
  key :excluded_from, do: excluded_from?(11..12)
end


IO.inspect TestSchema.rules
IO.inspect TestSchema.customs


ExUnit.start()
