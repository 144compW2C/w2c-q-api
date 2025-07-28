class CreateAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :answers, id: :bigint do |t|
      t.references :user, foreign_key: true
      t.references :problem, foreign_key: true
      t.references :selected_option, foreign_key: { to_table: :options }
      t.text :answer_text
      t.boolean :is_correct, default: false
      t.boolean :delete_flag, null: false, default: false
      t.timestamps
    end
  end
end