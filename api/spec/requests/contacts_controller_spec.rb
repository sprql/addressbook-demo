# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactsController do
  def last_modified_headers(id)
    head "/contacts/#{id}", headers: authorization_headers

    {
      'If-None-Match' => response.headers['ETag'],
      'If-Modified-Since' => response.headers['Last-Modified']
    }
  end

  context 'not authorized' do
    before do
      get '/contacts'
    end

    it do
      expect(response).to have_http_status(401)
    end
  end

  context 'authorized' do
    let(:authorization_headers) do
      {
        'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials('test', 'test')
      }
    end

    describe 'GET /contacts/' do
      context 'index' do
        before do
          Contact.create!(
            first_name: 'abc',
            phone: '123',
            address: 'Spain, Port Ardith, 240 McDermott Corner'
          )
          Contact.create!(
            first_name: 'bcd',
            phone: '456',
            address: 'United States of America, Jacobishire, 47099 Myah Fort'
          )

          get '/contacts', headers: authorization_headers
        end

        it do
          expect(response).to have_http_status(200)
          expect(response_data).to include(
            hash_including('attributes' => hash_including('first_name' => 'abc', 'phone' => '123', 'address' => 'Spain, Port Ardith, 240 McDermott Corner')),
            hash_including('attributes' => hash_including('first_name' => 'bcd', 'phone' => '456', 'address' => 'United States of America, Jacobishire, 47099 Myah Fort'))
          )
        end
      end

      context 'search' do
        let!(:sage_contact) do
          Contact.create!(first_name: 'Sage', last_name: 'Danie',
                          phone: '10000000000',
                          address: 'LakeCity')
        end

        let!(:berniece_conact) do
          Contact.create!(first_name: 'Berniece', last_name: 'Gutmann',
                          phone: '10001234567',
                          address: 'LakeCity')
        end

        let!(:john_contact) do
          Contact.create!(first_name: 'John', last_name: 'Gutmanner',
                          phone: '19001234567',
                          address: 'SaltCity')
        end

        context 'search by name' do
          before do
            get '/contacts?query=gut', headers: authorization_headers
          end

          it do
            expect(response).to have_http_status(200)

            expect(response_data).to include(hash_including('id' => john_contact.id))
            expect(response_data).to include(hash_including('id' => berniece_conact.id))

            expect(response_data).not_to include(hash_including('id' => sage_contact.id))
          end
        end

        context 'search by phone number' do
          before do
            get '/contacts?query=1000', headers: authorization_headers
          end

          it do
            expect(response).to have_http_status(200)

            expect(response_data).to include(hash_including('id' => berniece_conact.id))
            expect(response_data).to include(hash_including('id' => sage_contact.id))

            expect(response_data).not_to include(hash_including('id' => john_contact.id))
          end
        end

        context 'search by address' do
          before do
            get '/contacts?query=city', headers: authorization_headers
          end

          it do
            expect(response).to have_http_status(200)

            expect(response_data).to include(hash_including('id' => berniece_conact.id))
            expect(response_data).to include(hash_including('id' => sage_contact.id))
            expect(response_data).to include(hash_including('id' => john_contact.id))
          end
        end

        context 'not found' do
          before do
            get '/contacts?query=missing', headers: authorization_headers
          end

          it do
            expect(response).to have_http_status(200)
            expect(response_data).to be_empty
          end
        end
      end
    end

    describe 'POST /contacts/' do
      context 'success' do
        let(:params) do
          {
            data: {
              type: 'contact',
              attributes: {
                first_name: 'Bob'
              }
            }
          }
        end

        before do
          post '/contacts', params: params, headers: authorization_headers, as: :json
        end

        it do
          expect(response).to have_http_status(201)
          expect(response_data).to include('id' => String, 'type' => 'contact')
          expect(response.headers['Location']).to match(%r{/contacts/#{response_data['id']}$})
        end
      end

      context 'failure' do
        let(:params) do
          {
            data: {
              type: 'contact',
              attributes: {
                wrong_field: 'none'
              }
            }
          }
        end

        before do
          post '/contacts', params: params, headers: authorization_headers, as: :json
        end

        it do
          expect(response).to have_http_status(422)
          expect(response_errors).to be_present
        end
      end
    end

    describe 'GET /contacts/:id' do
      context 'not found' do
        before do
          get '/contacts/test', headers: authorization_headers
        end

        it do
          expect(response).to have_http_status(404)
        end
      end

      context 'success' do
        let(:contact) do
          Contact.create!(
            first_name: 'John',
            phone: '123',
            address: 'Spain, Port Ardith, 240 McDermott Corner'
          )
        end

        before do
          get "/contacts/#{contact.id}", headers: authorization_headers
        end

        it do
          expect(response).to have_http_status(200)
          expect(response_data).to include(
            'id' => contact.id,
            'attributes' => hash_including(
              'first_name' => 'John',
              'last_name' => nil,
              'phone' => '123',
              'address' => 'Spain, Port Ardith, 240 McDermott Corner'
            )
          )
        end
      end
    end

    describe 'PATCH /contacts/:id' do
      let!(:contact) { Contact.create!(first_name: 'Bob') }

      context 'not found' do
        before { patch '/contacts/test', headers: authorization_headers }

        it do
          expect(response).to have_http_status(404)
        end
      end

      context 'missing ETag' do
        before do
          patch "/contacts/#{contact.id}",
                params: { data: { type: 'contact' } },
                headers: authorization_headers,
                as: :json
        end

        it do
          expect(response).to have_http_status(403)
        end
      end

      context 'success' do
        let(:params) do
          {
            data: {
              type: 'contact',
              id: contact.id,
              attributes: {
                first_name: 'Bob',
                last_name: 'Gutmann',
                phone: '123',
                address: 'Lakecity'
              }
            }
          }
        end

        before do
          head "/contacts/#{contact.id}", headers: authorization_headers
          etag = response.headers['ETag']
          last_modified = response.headers['Last-Modified']

          patch "/contacts/#{contact.id}",
                params: params,
                headers: authorization_headers.merge(
                  'If-None-Match' => etag,
                  'If-Modified-Since' => last_modified
                ),
                as: :json

          contact.reload
        end

        it do
          expect(response).to have_http_status(204)
          expect(contact).to have_attributes(first_name: 'Bob',
                                             last_name: 'Gutmann',
                                             phone: '123',
                                             address: 'Lakecity')
        end
      end

      context 'stale' do
        let!(:contact) { Contact.create!(first_name: 'Bob') }

        let(:params) do
          {
            data: {
              type: 'contact',
              id: contact.id,
              attributes: {
                first_name: 'John'
              }
            }
          }
        end

        before do
          head "/contacts/#{contact.id}", headers: authorization_headers
          etag = response.headers['ETag']
          last_modified = response.headers['Last-Modified']

          contact.update!(first_name: 'Jovani')

          patch "/contacts/#{contact.id}",
                params: params,
                headers: authorization_headers.merge(
                  'If-None-Match' => etag,
                  'If-Modified-Since' => last_modified
                ),
                as: :json
        end

        it do
          expect(response).to have_http_status(412)
        end
      end
    end

    describe 'DELETE /contacts/:id' do
      context 'not found' do
        before { delete '/contacts/test', headers: authorization_headers }

        it do
          expect(response).to have_http_status(404)
        end
      end

      context 'success' do
        let(:contact) { Contact.create!(first_name: 'Bob') }

        before { delete "/contacts/#{contact.id}", headers: authorization_headers }

        it do
          expect(response).to have_http_status(204)
          expect(Contact.where(id: contact.id)).not_to be_exists
        end
      end
    end

    context 'handling errors' do
      context 'missing data param' do
        let(:contact) { Contact.create(first_name: 'Bob') }

        before do
          patch "/contacts/#{contact.id}",
                params: { id: 1 },
                headers: authorization_headers.merge(last_modified_headers(contact.id)),
                as: :json
        end

        it do
          expect(response).to have_http_status(422)
          expect(response_errors)
            .to include(hash_including('detail' => 'data: is missing'))
        end
      end
    end
  end
end
