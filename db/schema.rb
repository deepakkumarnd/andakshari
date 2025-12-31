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

ActiveRecord::Schema[8.0].define(version: 2025_12_31_102332) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "letters", force: :cascade do |t|
    t.text "letter"
    t.text "label_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "songs_count"
  end

  create_table "songs", force: :cascade do |t|
    t.text "lyrics"
    t.text "movie"
    t.integer "year"
    t.bigint "letter_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["letter_id"], name: "index_songs_on_letter_id"
  end

  add_foreign_key "songs", "letters"
end
