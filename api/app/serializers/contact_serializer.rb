# frozen_string_literal: true

class ContactSerializer
  include FastJsonapi::ObjectSerializer
  attributes :first_name,
             :last_name,
             :phone,
             :address
end
