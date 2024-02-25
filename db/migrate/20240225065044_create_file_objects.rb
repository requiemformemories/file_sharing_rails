# frozen_string_literal: true

class CreateFileObjects < ActiveRecord::Migration[7.1]
  def change
    create_table :file_objects do |t|
      t.string :key
      t.integer :bucket_id
      t.timestamps
    end
  end
end
