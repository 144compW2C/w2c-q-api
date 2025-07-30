class ProblemAsset < ApplicationRecord
  belongs_to :problem

  validates :file_type, presence: true
  validates :file_url, presence: true

  enum file_type: {
    image: "image",
    file: "file"
  }

  # 論理削除済みを除外するスコープ
  scope :active, -> { where(delete_flag: false) }
end