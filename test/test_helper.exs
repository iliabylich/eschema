defmodule TestSchema do
  use Schema.DSL

  defmodule Custom do
    def custom_predicate?(value) do
      value == "email@example.com"
    end
  end

  custom Custom

  ## Type checks
  key :int,       do: int?()
  key :str,       do: str?()
  # key :float,     do: float?
  # key :decimal,   do: decimal?
  # key :bool,      do: bool?
  # key :date,      do: date?
  # key :time,      do: time?
  # key :date_time, do: date_time?
  # key :array,     do: array?
  # key :hash,      do: hash?

  ## Boolean operations
  key :and, do: :left && :right
  key :or,  do: :left || :right
  key :if,  do: :left > :right
  key :xor, do: :left ^^^ :right

  ## Custom assertions
  key :custom,    do: :custom_predicate?

  ## Predefined checks
  key :none, do: none?()
  key :eql, do: eql?(5)
end


IO.inspect TestSchema.rules
IO.inspect TestSchema.customs


ExUnit.start()
