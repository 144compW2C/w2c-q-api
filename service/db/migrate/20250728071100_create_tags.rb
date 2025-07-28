class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags, id: :bigint do |t|
      t.text :tag_name, null: false
      t.boolean :delete_flag, null: false, default: false
      t.timestamps
    end
  end
end
