require 'addressbook_client/version'
require 'addressbook_client/api'

module AddressbookClient
  def self.authorize!(api_url:, username:, password:)
    API.new(api_url: api_url, username: username, password: password)
  end
end
