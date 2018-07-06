# frozen_string_literal: true

ContactParams = Dry::Validation.Params do
  required(:data).schema do
    optional(:attributes).schema do
      optional(:first_name).maybe(:str?).value(max_size?: 1000)
      optional(:last_name).maybe(:str?).value(max_size?: 1000)
      optional(:phone).maybe(:str?).value(max_size?: 1000)
      optional(:address).maybe(:str?).value(max_size?: 1000)
    end
  end
end
