defmodule ESchema.Validator do
  alias ESchema.Visitor

  def call(schema, params) do
    case Visitor.call({:schema, schema}, params) do
      {:errors, _} -> "localized"
      {:ok, _} = success -> success
    end
  end
end
