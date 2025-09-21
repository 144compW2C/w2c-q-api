# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
puts "Seeding start..."

# ======= Users =======
User.destroy_all
u_admin = User.create!(
  name: "管理者 太郎",
  email: "admin@example.com",
  password: "Password123",
  password_confirmation: "Password123",
  role: "reviewer",
  class_name: "T1"
)

u_general = User.create!(
  name: "一般 花子",
  email: "user@example.com",
  password: "Password123",
  password_confirmation: "Password123",
  role: "general",
  class_name: "A1"
)

# ======= Tags =======
Tag.destroy_all
tag_names = %w[HTML CSS JS Illustrator Photoshop figma 色彩]
tags = tag_names.map { |name| Tag.create!(tag_name: name) }
tag_html, tag_css, tag_js = tags[0], tags[1], tags[2]

# ======= Statuses =======
Status.destroy_all
# 設計：0:下書き 1:承認待ち 2:公開中 3:返却 4:却下
st_draft     = Status.create!(status_name: "下書き")
st_pending   = Status.create!(status_name: "承認待ち")
st_published = Status.create!(status_name: "公開中")
st_returned  = Status.create!(status_name: "返却")
st_rejected  = Status.create!(status_name: "却下")

# ======= Problems =======
Problem.destroy_all
p1 = Problem.create!(
  title: "HTMLの基本タグ",
  body: "h1〜h3 で見出しを作ってください。",
  tag: tag_html,
  status: st_published,
  creator: u_general,
  reviewer: u_admin,
  level: 1,
  difficulty: 1,
  is_multiple_choice: false,
  model_answer: "<h1>見出し</h1>\n<h2>小見出し</h2>\n<h3>さらに小見出し</h3>",
  reviewed_at: Time.current
)

p2 = Problem.create!(
  title: "色はどれ？",
  body: "赤を表す 16 進カラーコードを選んでください。",
  tag: tag_css,
  status: st_published,
  creator: u_general,
  reviewer: u_admin,
  level: 1,
  difficulty: 2,
  is_multiple_choice: true,
  model_answer: "#f00",
  reviewed_at: Time.current
)

# ======= Options（p2 は選択式）=======
Option.destroy_all
Option.create!(problem: p2, input_type: "choice", option_name: "A", content: "#00f")
Option.create!(problem: p2, input_type: "choice", option_name: "B", content: "#0f0")
opt_c = Option.create!(problem: p2, input_type: "choice", option_name: "C", content: "#f00") # 正解
Option.create!(problem: p2, input_type: "choice", option_name: "D", content: "#ff0")

# ======= ProblemAssets（画像やファイルのダミー）=======
ProblemAsset.destroy_all
ProblemAsset.create!(
  problem: p1, file_type: "image",
  file_name: "heading_example.png",
  content_type: "image/png",
  file_url: "https://example.com/assets/heading_example.png"
)
ProblemAsset.create!(
  problem: p2, file_type: "image",
  file_name: "color_wheel.png",
  content_type: "image/png",
  file_url: "https://example.com/assets/color_wheel.png"
)

# ======= Answers（ダミー回答）=======
Answer.destroy_all
Answer.create!(
  user: u_general,
  problem: p2,
  selected_option: opt_c,
  answer_text: opt_c.content,
  is_correct: true
)

puts "Seeding done!"