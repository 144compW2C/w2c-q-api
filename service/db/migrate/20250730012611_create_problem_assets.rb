class CreateProblemAssets < ActiveRecord::Migration[7.1]
  def change
    create_table :problem_assets, id: :bigint do |t|
      t.references :problem, null: false, foreign_key: true       # 紐づく問題
      t.string :file_type, null: false                            # "image", "file" など
      t.string :file_name                                         # ファイル名（例: image01.png）
      t.string :content_type                                      # MIMEタイプ（例: image/png, application/pdf）
      t.text :file_url, null: false                               # URL（CloudinaryやS3など）
      t.boolean :delete_flag, null: false, default: false         # 論理削除
      t.timestamps
    end
  end
end