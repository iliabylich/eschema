defmodule ESchema.Validator do
  def call(schema, params) do
    case ESchema.Visitor.call({:schema, schema}, params) do
      {:errors, errors} -> "localized"
      {:ok, output} = success -> success
    end
  end
end
