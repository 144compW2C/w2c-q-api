class CreateStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :statuses, id: :bigint do |t|
      t.text :status_name, null: false
      t.boolean :delete_flag, null: false, default: false
      t.timestamps
    end
  end
end