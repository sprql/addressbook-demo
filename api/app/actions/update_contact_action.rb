# frozen_string_literal: true

class UpdateContactAction
  def initialize(contact, params)
    @contact = contact
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      destroy_unspecified_phones
      destroy_unspecified_addresses
      @contact.update!(@params)
      destroy_empty_relationships
    end
  end

  def destroy_unspecified_phones
    request_phones_ids = @params[:phones_attributes]&.map { |i| i[:id] }
    @contact.phones.where.not(id: request_phones_ids).destroy_all if request_phones_ids.present?
  end

  def destroy_unspecified_addresses
    request_addresses_ids = @params[:addresses_attributes]&.map { |i| i[:id] }
    @contact.addresses.where.not(id: request_addresses_ids).destroy_all if request_addresses_ids.present?
  end

  def destroy_empty_relationships
    @contact.phones.destroy_all if @params[:phones_attributes]&.empty?
    @contact.addresses.destroy_all if @params[:addresses_attributes]&.empty?
  end
end
