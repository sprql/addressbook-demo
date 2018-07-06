# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |_e|
      head :not_found
    end

    rescue_from ActionController::ParameterMissing do |e|
      # TODO: workaround for https://github.com/rails/rails/issues/25106
      self.response_body = nil
      @_response_body = nil

      render json: { errors: [{ status: 422, detail: e.message }] },
             status: :unprocessable_entity
    end
  end
end
