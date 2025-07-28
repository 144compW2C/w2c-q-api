class Status < ApplicationRecord
  include SoftDeletable

  has_many :problems

  validates :status_name, presence: true
end