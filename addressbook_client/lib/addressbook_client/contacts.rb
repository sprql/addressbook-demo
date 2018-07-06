module AddressbookClient
  class Contacts
    class Contact < Struct.new(:id, :first_name, :last_name, :phone, :address)
      def short_id
        id[0..7]
      end
    end

    Error = Struct.new(:status, :source, :detail)

    def initialize(connection:, upload_connection:)
      @connection = connection
      @upload_connection = upload_connection
    end

    def get(id = nil)
      build_result(connection.get("/contacts/#{id}"))
    end

    def search(query)
      build_result(connection.get('/contacts', query: query))
    end

    def create(first_name:, last_name:, phone:, address:)
      data = {
        type: 'contact',
        attributes: {
          first_name: first_name,
          last_name: last_name,
          phone: phone,
          address: address
        }
      }
      post(data)
    end

    def post(data)
      build_result(connection.post('/contacts', data: data))
    end

    def update_field(id, field, value)
      data = {
        id: id,
        type: 'contact',
        attributes: {
          field => value
        }
      }
      patch(id, data)
    end

    def patch(id, data)
      build_result(connection.patch("/contacts/#{id}",
                                    { data: data },
                                    last_modified_headers("/contacts/#{id}")))
    end

    def upload(id, path)
      data = Faraday::UploadIO.new(path, 'image/jpeg')
      build_result(upload_connection.post("/contacts/#{id}/upload",
                                           { data: data },
                                           last_modified_headers("/contacts/#{id}")))
    end

    def delete(id)
      build_result(connection.delete("/contacts/#{id}"))
    end

    private

    attr_reader :connection,
                :upload_connection

    def last_modified_headers(url)
      response = connection.head(url)

      {
        'If-None-Match' => response.headers['etag'],
        'If-Modified-Since' => response.headers['last-modified']
      }
    end

    def build_result(response)
      if response.success?
        data = response.body['data'] ? wrap_data(response.body['data']) : nil
        API::Result.new(data, response.status)
      else
        API::Result.new(nil, response.status, wrap_errors(response.body['errors']))
      end
    end

    def wrap_data(data)
      data.is_a?(Array) ? data.map(&method(:hash_to_contact)) : hash_to_contact(data)
    end

    def hash_to_contact(data)
      attrs = data['attributes']
      Contact.new(data['id'], attrs['first_name'], attrs['last_name'], attrs['phone'], attrs['address'])
    end

    def wrap_errors(errors)
      Array(errors).map { |error| Error.new(error['status'], error['source'], error['detail']) }
    end
  end
end
