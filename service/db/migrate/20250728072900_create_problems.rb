class CreateProblems < ActiveRecord::Migration[7.1]
  def change
    create_table :problems, id: :bigint do |t|
      t.text :title, null: false
      t.text :body
      t.references :tag, foreign_key: true
      t.references :status, foreign_key: true
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :reviewer, foreign_key: { to_table: :users }
      t.integer :level
      t.integer :difficulty
      t.boolean :is_multiple_choice
      t.text :model_answer
      t.datetime :reviewed_at
      t.boolean :delete_flag, null: false, default: false

      t.timestamps
    end
  end
end