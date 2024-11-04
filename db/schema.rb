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

ActiveRecord::Schema[7.2].define(version: 2024_11_04_090402) do
  create_table "boards", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.string "description"
    t.index [ "name" ], name: "index_boards_on_name", unique: true
    t.index [ "team_id" ], name: "index_boards_on_team_id"
  end

  create_table "devise_api_tokens", force: :cascade do |t|
    t.string "resource_owner_type", null: false
    t.bigint "resource_owner_id", null: false
    t.string "access_token", null: false
    t.string "refresh_token"
    t.integer "expires_in", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "access_token" ], name: "index_devise_api_tokens_on_access_token"
    t.index [ "previous_refresh_token" ], name: "index_devise_api_tokens_on_previous_refresh_token"
    t.index [ "refresh_token" ], name: "index_devise_api_tokens_on_refresh_token"
    t.index [ "resource_owner_type", "resource_owner_id" ], name: "index_devise_api_tokens_on_resource_owner"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id"
    t.text "message"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "user_id" ], name: "index_notifications_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "board_id"
    t.bigint "user_id"
    t.integer "status", default: 0
    t.integer "priority", default: 1
    t.index [ "user_id" ], name: "index_tasks_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.index [ "name" ], name: "index_teams_on_name", unique: true
  end

  create_table "teams_users", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "team_id", null: false
    t.index [ "team_id" ], name: "index_teams_users_on_team_id"
    t.index [ "user_id" ], name: "index_teams_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.bigint "team_id"
    t.string "first_name"
    t.string "last_name"
    t.index [ "email" ], name: "index_users_on_email", unique: true
    t.index [ "reset_password_token" ], name: "index_users_on_reset_password_token", unique: true
    t.index [ "team_id" ], name: "index_users_on_team_id"
  end

  add_foreign_key "boards", "teams", on_delete: :nullify
  add_foreign_key "notifications", "users"
  add_foreign_key "tasks", "users"
  add_foreign_key "users", "teams"
end
