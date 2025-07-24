class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.text :name, null: false
      t.text :email, null: false , unique: true
      t.text :password_hash, null: false
      t.text :role, null: false
      t.text :class_name
      t.boolean :delete_flag, null: false, default: false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
