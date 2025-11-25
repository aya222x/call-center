class CreateCallRecordings < ActiveRecord::Migration[8.0]
  def change
    create_table :call_recordings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :call_script, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :language, null: false, default: 1
      t.date :call_date, null: false
      t.integer :duration_seconds
      t.text :transcript
      t.string :customer_name
      t.string :customer_phone
      t.text :error_message

      t.timestamps
    end
    add_index :call_recordings, :status
    add_index :call_recordings, :language
    add_index :call_recordings, :call_date
    add_index :call_recordings, [:user_id, :call_date]
  end
end
