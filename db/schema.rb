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

ActiveRecord::Schema[8.0].define(version: 2026_03_30_000000) do
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

  create_table "edit_logs", force: :cascade do |t|
    t.bigint "song_id", null: false
    t.bigint "user_id", null: false
    t.string "field", null: false
    t.text "old_value"
    t.text "new_value", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id", "status"], name: "index_edit_logs_on_song_id_and_status"
    t.index ["song_id", "user_id", "field"], name: "index_edit_logs_on_song_id_and_user_id_and_field"
    t.index ["song_id"], name: "index_edit_logs_on_song_id"
    t.index ["user_id"], name: "index_edit_logs_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "song_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id"], name: "index_likes_on_song_id"
    t.index ["user_id", "song_id"], name: "index_likes_on_user_id_and_song_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "song_tags", force: :cascade do |t|
    t.bigint "song_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["song_id", "tag_id"], name: "index_song_tags_on_song_id_and_tag_id", unique: true
    t.index ["song_id"], name: "index_song_tags_on_song_id"
    t.index ["tag_id"], name: "index_song_tags_on_tag_id"
  end

  create_table "songs", force: :cascade do |t|
    t.text "lyrics"
    t.text "movie"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "start_letter"
    t.integer "likes_count", default: 0, null: false
    t.bigint "user_id"
    t.index ["start_letter"], name: "index_songs_on_start_letter"
    t.index ["user_id"], name: "index_songs_on_user_id"
    t.index ["year"], name: "index_songs_on_year"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
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
  add_foreign_key "edit_logs", "songs"
  add_foreign_key "edit_logs", "users"
  add_foreign_key "likes", "songs"
  add_foreign_key "likes", "users"
  add_foreign_key "song_tags", "songs"
  add_foreign_key "song_tags", "tags"
  add_foreign_key "songs", "users"
end
