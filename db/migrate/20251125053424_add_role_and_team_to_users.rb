class AddRoleAndTeamToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    add_reference :users, :team, null: true, foreign_key: true

    add_index :users, :role
  end
end
