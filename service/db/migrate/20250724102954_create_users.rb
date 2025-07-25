class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false
      t.string :class_name
      t.boolean :delete_flag, null: false, default: false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
