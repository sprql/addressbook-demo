# frozen_string_literal: true

class Contact < ApplicationRecord
  def self.search(query)
    where('id::text ILIKE ?', "%#{query}%")
      .or(where('first_name ILIKE ?', "%#{query}%"))
      .or(where('last_name ILIKE ?', "%#{query}%"))
      .or(where('phone ILIKE ?', "%#{query}%"))
      .or(where('address ILIKE ?', "%#{query}%"))
  end

  validate :first_name_or_last_name_present

  private

  def first_name_or_last_name_present
    errors[:base] << :missing_first_name_or_last_name if first_name.blank? && last_name.blank?
  end
end
