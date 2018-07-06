require 'faraday_middleware'
require 'addressbook_client/contacts'
require 'json'

module AddressbookClient
  class API
    class Result < Struct.new(:data, :status, :errors)
      def success?
        status >= 200 && status < 300
      end
    end

    def initialize(api_url:, username:, password:)
      @api_url = api_url
      @username = username
      @password = password
    end

    def contacts
      @contacts ||= Contacts.new(connection: connection, upload_connection: upload_connection)
    end

    private

    def connection
      @connection ||= Faraday.new(@api_url) do |conn|
        conn.basic_auth(@username, @password)
        conn.request :json
        # conn.response :logger
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end

    def upload_connection
      @upload_connection ||= Faraday.new(@api_url) do |conn|
        conn.basic_auth(@username, @password)
        conn.request :multipart
        conn.request :url_encoded
        # conn.response :logger
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
