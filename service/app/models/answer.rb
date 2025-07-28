class Answer < ApplicationRecord
  include SoftDeletable

  belongs_to :user
  belongs_to :problem
  belongs_to :selected_option, class_name: 'Option', optional: true

  validates :is_correct, inclusion: { in: [true, false] }
end