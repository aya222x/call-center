class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.references :department, null: false, foreign_key: true
      t.references :supervisor, null: true, foreign_key: { to_table: :users }
      t.datetime :deactivated_at

      t.timestamps
    end
    add_index :teams, [:department_id, :name], unique: true
    add_index :teams, :deactivated_at
  end
end
