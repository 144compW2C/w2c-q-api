class CreateOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :options, id: :bigint do |t|
      t.references :problem, foreign_key: true
      t.text :input_type, null: false
      t.text :option_name
      t.text :content
      t.text :language
      t.text :editor_template
      t.boolean :delete_flag, null: false, default: false
      t.timestamps
    end
  end
end