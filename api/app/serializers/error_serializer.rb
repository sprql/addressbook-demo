# frozen_string_literal: true

class ErrorSerializer
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def serialized_json
    serializable_hash.to_json
  end

  def serializable_hash
    {
      errors: errors
    }
  end

  def errors
    object.errors.messages.flat_map do |field, errors|
      errors.map do |error_message|
        {
          status: 422,
          source: { pointer: "/data/attributes/#{field}" },
          detail: error_message
        }
      end
    end
  end
end
