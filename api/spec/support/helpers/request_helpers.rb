# frozen_string_literal: true

module RequestHelpers
  extend ActiveSupport::Concern

  included do
    let(:response_json) { JSON.parse(response.body) }
    let(:response_data) { response_json.fetch('data') }
    let(:response_included) { response_json.fetch('included') }
    let(:response_errors) { response_json.fetch('errors') }
  end
end
