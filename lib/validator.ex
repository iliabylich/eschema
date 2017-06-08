defmodule ESchema.Validator do
  @moduledoc false

  alias ESchema.Visitor

  def call(schema, params) do
    case Visitor.call({:schema, schema}, params) do
      {:error, _} -> "localized"
      {:ok, _} = success -> success
    end
  end
end
