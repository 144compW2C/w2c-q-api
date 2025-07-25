class User < ApplicationRecord
  # password hash用
  has_secure_password

  # バリデーション
  # name は NOT NULL 指定なので空チェック必須。
  validates :name, presence: true
  # ユニーク制約と必須チェック（DB側でも add_index :email, unique: true で制約済）。
  validates :email, presence: true, uniqueness: true
  # has_secure_password を使うときは password_digest ではなく password に対してバリデーションをかける。
  validates :password, presence: true, length: { minimum: 6 }  # 仮想属性なので password_digest でなく password に対して
  # 'general' または 'reviewer' しか入れないように制限。
  validates :role, presence: true, inclusion: { in: %w[general reviewer] }

  # 論理削除を扱うスコープ（任意）
  # 論理削除されていないユーザーだけを取得する便利スコープ（使い方例：User.active）
  scope :active, -> { where(delete_flag: false) }
end
