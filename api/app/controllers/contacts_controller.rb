# frozen_string_literal: true

class ContactsController < ApplicationController
  before_action :find_contact, only: %i[show image upload update destroy]

  def index
    query = params[:query]&.strip

    contacts = Contact.order(first_name: :asc, last_name: :asc)
    contacts = contacts.search(query) if query.present?

    render_contact_json(contacts)
  end

  def create
    result = ContactParams.call(params.permit!.to_hash)
    return render_params_error(result.errors) if result.failure?
    contact_params = transform_params_to_attributes(result.to_hash)

    contact = Contact.new(contact_params)
    if contact.save
      render_contact_json(contact, status: :created, location: contact)
    else
      render json: ErrorSerializer.new(contact).serialized_json,
             status: :unprocessable_entity
    end
  end

  def show
    fresh_when(@contact)
    render_contact_json(@contact)
  end

  def upload
    image = params.require(:data)

    @contact.update(image: image.read)
    head :no_content
  end

  def image
    mime = MimeMagic.by_magic(@contact.image)

    send_data @contact.image,
              filename: @contact.id,
              type: mime.type,
              disposition: 'inline'
  end

  def update
    result = ContactParams.call(params.permit!.to_hash)
    return render_params_error(result.errors) if result.failure?
    contact_params = transform_params_to_attributes(result.to_hash)

    return head(:forbidden) unless request.if_none_match && request.if_modified_since
    return head(:precondition_failed) if stale?(@contact)

    UpdateContactAction.new(@contact, contact_params).call

    head :no_content
  end

  def destroy
    @contact.destroy
    head :no_content
  end

  private

  def find_contact
    @contact = Contact.find_by!(id: params[:id])
  end

  def render_contact_json(data, options = {})
    json = ContactSerializer.new(data).serialized_json
    render(options.merge(json: json))
  end

  def transform_params_to_attributes(params)
    params.dig(:data, :attributes)
  end
end
