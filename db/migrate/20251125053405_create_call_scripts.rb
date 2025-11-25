class CreateCallScripts < ActiveRecord::Migration[8.0]
  def change
    create_table :call_scripts do |t|
      t.string :name, null: false
      t.integer :call_type, null: false, default: 0
      t.text :content, null: false
      t.references :department, null: false, foreign_key: true
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :call_scripts, :call_type
    add_index :call_scripts, :active
  end
end
