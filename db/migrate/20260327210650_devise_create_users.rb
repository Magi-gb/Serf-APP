# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :username,           null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.integer :role,              null: false, default: 0

      t.timestamps null: false
    end

    add_index :users, :username, unique: true
  end
end
