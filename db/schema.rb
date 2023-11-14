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

ActiveRecord::Schema[7.1].define(version: 2023_11_14_133439) do
  create_table "calendars", force: :cascade do |t|
    t.string "label"
    t.string "alternateLabel"
    t.string "detail"
    t.string "value"
    t.datetime "startDate"
    t.datetime "endDate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.integer "week"
    t.integer "remote_game_id"
    t.integer "set_odds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "favored_team_id"
    t.float "odds"
  end

  create_table "group_games", force: :cascade do |t|
    t.integer "game_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_managers", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "group_picks", force: :cascade do |t|
    t.integer "pick_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.boolean "is_private", default: false
  end

  create_table "matchups", force: :cascade do |t|
    t.string "remote_id"
    t.string "sport_key"
    t.string "sport_title"
    t.datetime "commence_time"
    t.boolean "completed", default: false, null: false
    t.string "home_team"
    t.string "away_team"
    t.datetime "remote_last_updated"
    t.json "scores"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "bookmakers"
  end

  create_table "odds", force: :cascade do |t|
    t.string "remote_id"
    t.string "title"
    t.datetime "last_update"
    t.string "market_type"
    t.string "name"
    t.string "price"
    t.string "point"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "picks", force: :cascade do |t|
    t.integer "week"
    t.integer "remote_game_id"
    t.integer "confidence"
    t.integer "remote_team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "game_id"
    t.boolean "winner", default: false
  end

  create_table "user_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
