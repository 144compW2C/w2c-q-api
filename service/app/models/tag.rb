class Tag < ApplicationRecord
  include SoftDeletable

  has_many :problems

  validates :tag_name, presence: true
end