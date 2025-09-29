class AddLockVersionToAllTables < ActiveRecord::Migration[7.1]
  def change
    add_column :users,          :lock_version, :integer, null: false, default: 0
    add_column :problems,       :lock_version, :integer, null: false, default: 0
    add_column :answers,        :lock_version, :integer, null: false, default: 0
    add_column :options,        :lock_version, :integer, null: false, default: 0
    add_column :problem_assets, :lock_version, :integer, null: false, default: 0
  end
end