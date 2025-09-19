class AddContextTypeToProblemAssets < ActiveRecord::Migration[7.1]
  def change
    add_column :problem_assets, :context_type, :text
  end
end