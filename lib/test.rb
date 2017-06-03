require 'dry-validation'

UserSchema = Dry::Validation.Schema do
  required(:a) { gt?(5) }
end

p UserSchema.call(a: "asd")
