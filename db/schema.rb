# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_21_083512) do

  create_table "access_histories", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "battle_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_access_histories_on_account_id"
    t.index ["battle_id"], name: "index_access_histories_on_battle_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "tag", null: false
    t.integer "player_id"
    t.string "note"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_accounts_on_player_id"
    t.index ["tag"], name: "index_accounts_on_tag", unique: true
  end

  create_table "battle_types", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_battle_types_on_name", unique: true
  end

  create_table "battles", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "battle_type_id", null: false
    t.datetime "time", null: false
    t.string "time_code", null: false
    t.integer "duration"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["battle_type_id"], name: "index_battles_on_battle_type_id"
    t.index ["event_id"], name: "index_battles_on_event_id"
  end

  create_table "brawlers", force: :cascade do |t|
    t.integer "bs_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bs_id"], name: "index_brawlers_on_bs_id", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.integer "bs_id", null: false
    t.integer "mode_id", null: false
    t.integer "map_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bs_id"], name: "index_events_on_bs_id", unique: true
    t.index ["map_id"], name: "index_events_on_map_id"
    t.index ["mode_id"], name: "index_events_on_mode_id"
  end

  create_table "maps", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_maps_on_name", unique: true
  end

  create_table "modes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_modes_on_name", unique: true
  end

  create_table "picks", force: :cascade do |t|
    t.integer "battle_id", null: false
    t.integer "account_id", null: false
    t.integer "brawler_id", null: false
    t.integer "team_id", null: false
    t.integer "power"
    t.integer "trophies"
    t.integer "trophy_change"
    t.boolean "is_mvp"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_picks_on_account_id"
    t.index ["battle_id"], name: "index_picks_on_battle_id"
    t.index ["brawler_id"], name: "index_picks_on_brawler_id"
    t.index ["team_id"], name: "index_picks_on_team_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_players_on_name", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "name"
    t.integer "highestTrophies"
    t.integer "highestPowerPlayPoints"
    t.boolean "isQualifiedFromChampionshipChallenge"
    t.integer "threeVsThreeVictories"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_profiles_on_account_id", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.string "result"
    t.integer "rank"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "access_histories", "accounts"
  add_foreign_key "access_histories", "battles"
  add_foreign_key "accounts", "players"
  add_foreign_key "battles", "battle_types"
  add_foreign_key "battles", "events"
  add_foreign_key "events", "maps"
  add_foreign_key "events", "modes"
  add_foreign_key "picks", "accounts"
  add_foreign_key "picks", "battles"
  add_foreign_key "picks", "brawlers"
  add_foreign_key "picks", "teams"
  add_foreign_key "profiles", "accounts"
end
