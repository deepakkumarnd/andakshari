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

ActiveRecord::Schema[8.0].define(version: 2026_03_28_123440) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "chunks", force: :cascade do |t|
    t.bigint "song_id", null: false
    t.text "content", null: false
    t.vector "embedding", limit: 768
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('simple'::regconfig, content)", name: "index_chunks_on_content_fulltext", using: :gin
    t.index ["embedding"], name: "index_chunks_on_embedding", opclass: :vector_cosine_ops, using: :hnsw
    t.index ["song_id"], name: "index_chunks_on_song_id"
  end

  create_table "songs", force: :cascade do |t|
    t.text "lyrics"
    t.text "movie"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "start_letter"
    t.index ["start_letter"], name: "index_songs_on_start_letter"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "otp_code"
    t.datetime "otp_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "chunks", "songs"
end
