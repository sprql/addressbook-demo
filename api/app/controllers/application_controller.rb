# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ExceptionHandler

  http_basic_authenticate_with name: Rails.configuration.basic_authentication_name,
                               password: Rails.configuration.basic_authentication_password

  protected

  def render_params_error(errors)
    error_list = errors.map do |e|
      detail = "#{e[0]}: #{e[1].join(', ')}"

      { status: 422, detail: detail }
    end

    render json: { errors: error_list },
           status: :unprocessable_entity
  end
end
