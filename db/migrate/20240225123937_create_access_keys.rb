# frozen_string_literal: true

class CreateAccessKeys < ActiveRecord::Migration[7.1]
  def change
    create_table :access_keys do |t|
      t.string :access_id, null: false
      t.integer :user_id, null: false
      t.string :secret, null: false
      t.datetime :revoked_at
      t.datetime :expired_at

      t.timestamps
    end
  end
end
