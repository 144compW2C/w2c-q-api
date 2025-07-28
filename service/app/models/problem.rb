class Problem < ApplicationRecord
  include SoftDeletable

  belongs_to :tag, optional: true
  belongs_to :status, optional: true
  belongs_to :creator, class_name: 'User'
  belongs_to :reviewer, class_name: 'User', optional: true

  has_many :options, dependent: :destroy
  has_many :answers, dependent: :destroy

  validates :title, presence: true


  before_save :set_reviewed_at, if: :status_id_changed?
  private
  def set_reviewed_at
    # たとえば「2 = レビュー済み」のようなルールがあれば
    if status&.status_name == 'レビュー済み'
      self.reviewed_at ||= Time.current
    end
  end
end