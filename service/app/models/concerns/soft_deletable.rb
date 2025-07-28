# app/models/concerns/soft_deletable.rb
module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(delete_flag: false) }
    scope :deleted, -> { where(delete_flag: true) }
  end

  def soft_delete
    update(delete_flag: true)
  end

  def restore
    update(delete_flag: false)
  end

  def deleted?
    delete_flag
  end
end

# 使い方
# User.active             # ← delete_flag: false のみ
# User.deleted            # ← delete_flag: true のみ
# user.soft_delete        # ← 論理削除
# user.restore            # ← 復元
# user.deleted?           # ← 論理削除済みか確認