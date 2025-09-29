class Option < ApplicationRecord
  include SoftDeletable

  belongs_to :problem
  has_many :answers

  validates :input_type, presence: true

  # A, B, C... のラベルを返す
  def self.label_for(index)
    ("A".ord + index).chr
  end
end