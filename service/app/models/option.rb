class Option < ApplicationRecord
  include SoftDeletable

  belongs_to :problem
  has_many :answers

  validates :input_type, presence: true
end