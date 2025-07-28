class User < ApplicationRecord
  # password hash用
  has_secure_password

  # バリデーション
  # name は NOT NULL 指定なので空チェック必須。
  # ユニーク制約と必須チェック（DB側でも add_index :email, unique: true で制約済）。
  # has_secure_password を使うときは password_digest ではなく password に対してバリデーションをかける。
  # 仮想属性なので password_digest でなく password に対して
  # 'general' または 'reviewer' しか入れないように制限。
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }  
  validates :role, presence: true, inclusion: { in: %w[general reviewer] }

  # 論理削除を扱うスコープ（任意）
  # 論理削除されていないユーザーだけを取得する便利スコープ（使い方例：User.active）
  scope :active, -> { where(delete_flag: false) }

  #  関連付け
  # ユーザーは問題を作成したりレビューしたりするので、
  # creator_id と reviewer_id を使って Problem モデルと関連付ける。
  # ここでは、creator と reviewer の両方を User モデルに関連付けている。
  has_many :created_problems, class_name: 'Problem', foreign_key: 'creator_id'
  has_many :reviewed_problems, class_name: 'Problem', foreign_key: 'reviewer_id'

  # ソフトデリートを扱うためのモジュールをインクルード
  include SoftDeletable
end
