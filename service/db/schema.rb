# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_07_30_012611) do
  create_table "answers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "problem_id"
    t.bigint "selected_option_id"
    t.text "answer_text"
    t.boolean "is_correct", default: false
    t.boolean "delete_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id"], name: "index_answers_on_problem_id"
    t.index ["selected_option_id"], name: "index_answers_on_selected_option_id"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "options", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "problem_id"
    t.text "input_type", null: false
    t.text "option_name"
    t.text "content"
    t.text "language"
    t.text "editor_template"
    t.boolean "delete_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id"], name: "index_options_on_problem_id"
  end

  create_table "problem_assets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "problem_id", null: false
    t.string "file_type", null: false
    t.string "file_name"
    t.string "content_type"
    t.text "file_url", null: false
    t.boolean "delete_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id"], name: "index_problem_assets_on_problem_id"
  end

  create_table "problems", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "title", null: false
    t.text "body"
    t.bigint "tag_id"
    t.bigint "status_id"
    t.bigint "creator_id", null: false
    t.bigint "reviewer_id"
    t.integer "level"
    t.integer "difficulty"
    t.boolean "is_multiple_choice"
    t.text "starter_code"
    t.text "answer_sample"
    t.datetime "reviewed_at"
    t.boolean "delete_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_problems_on_creator_id"
    t.index ["reviewer_id"], name: "index_problems_on_reviewer_id"
    t.index ["status_id"], name: "index_problems_on_status_id"
    t.index ["tag_id"], name: "index_problems_on_tag_id"
  end

  create_table "statuses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "status_name", null: false
    t.boolean "delete_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "tag_name", null: false
    t.boolean "delete_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", null: false
    t.string "class_name"
    t.boolean "delete_flag", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "answers", "options", column: "selected_option_id"
  add_foreign_key "answers", "problems"
  add_foreign_key "answers", "users"
  add_foreign_key "options", "problems"
  add_foreign_key "problem_assets", "problems"
  add_foreign_key "problems", "statuses"
  add_foreign_key "problems", "tags"
  add_foreign_key "problems", "users", column: "creator_id"
  add_foreign_key "problems", "users", column: "reviewer_id"
end
