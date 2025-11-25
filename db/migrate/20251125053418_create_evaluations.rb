class CreateEvaluations < ActiveRecord::Migration[8.0]
  def change
    create_table :evaluations do |t|
      t.references :call_recording, null: false, foreign_key: true, index: { unique: true }
      t.decimal :overall_score, null: false, precision: 5, scale: 2
      t.decimal :script_adherence_score, precision: 5, scale: 2
      t.decimal :politeness_score, precision: 5, scale: 2
      t.decimal :resolution_speed_score, precision: 5, scale: 2
      t.decimal :terminology_score, precision: 5, scale: 2
      t.decimal :success_score, precision: 5, scale: 2
      t.text :recommendations

      t.timestamps
    end
    add_index :evaluations, :overall_score
  end
end
