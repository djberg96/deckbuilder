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

ActiveRecord::Schema[7.2].define(version: 2024_12_02_033818) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id"
  end

  create_table "deck_cards", force: :cascade do |t|
    t.bigint "card_id"
    t.bigint "deck_id"
    t.integer "quantity"
    t.index ["card_id", "deck_id"], name: "index_deck_cards_on_card_id_and_deck_id", unique: true
    t.index ["card_id"], name: "index_deck_cards_on_card_id"
    t.index ["deck_id"], name: "index_deck_cards_on_deck_id"
  end

  create_table "decks", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.boolean "private", default: false
  end

  create_table "game_decks", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "deck_id"
    t.integer "quantity"
    t.index ["deck_id"], name: "index_game_decks_on_deck_id"
    t.index ["game_id", "deck_id"], name: "index_game_decks_on_game_id_and_deck_id", unique: true
    t.index ["game_id"], name: "index_game_decks_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "maximum_cards_per_deck"
    t.integer "minimum_cards_per_deck"
    t.integer "maximum_individual_cards"
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "edition"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "private"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_groups", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "group_id"
    t.index ["group_id"], name: "index_user_groups_on_group_id"
    t.index ["user_id", "group_id"], name: "index_user_groups_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_user_groups_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "password_digest"
    t.boolean "private", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "cards", "games"
  add_foreign_key "deck_cards", "cards"
  add_foreign_key "deck_cards", "decks"
  add_foreign_key "decks", "users"
  add_foreign_key "game_decks", "decks"
  add_foreign_key "game_decks", "games"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
end
