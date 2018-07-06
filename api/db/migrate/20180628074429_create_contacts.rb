# frozen_string_literal: true

class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    execute 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'

    create_table :contacts, id: :uuid, default: 'uuid_generate_v4()' do |t|
      t.binary :image
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :address
      t.timestamps
    end
  end
end
