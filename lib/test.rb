require 'dry-validation'

UserSchema = Dry::Validation.Schema do
  required(:a) { int? }
end

p UserSchema.rules
