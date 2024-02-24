# frozen_string_literal: true

class CreateBuckets < ActiveRecord::Migration[7.1]
  def change
    create_table :buckets do |t|
      t.integer :user_id
      t.string :name
      t.timestamps
    end
  end
end
