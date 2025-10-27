class AddPasswordVersionToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :password_version, :integer, default: 1, null: false
  end
end
