require 'spec_helper'
require 'addressbook_client/api'

RSpec.describe AddressbookClient::API do
  describe '#contacts' do
    subject do
      described_class.new(api_url: 'http://localhost:9292/',
                          username: 'development',
                          password: 'development')
                     .contacts
    end

    it do
      expect(subject.get).to have_attributes(success?: true, data: Array, status: 200, errors: nil)
    end

    it do
      expect(subject.get('893898a4-4881-4b2a-9a29-03d9b270604f'))
        .to have_attributes(success?: true, data: Struct, status: 200, errors: nil)
    end
  end
end
