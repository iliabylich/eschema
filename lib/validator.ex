defmodule ESchema.Validator do
  def call(schema, params) do
    case ESchema.Visitor.call({:schema, schema}, params) do
      {:errors, _} -> "localized"
      {:ok, _} = success -> success
    end
  end
end
