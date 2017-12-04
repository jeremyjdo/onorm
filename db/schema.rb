# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171204144317) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "analyses", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "total_score"
    t.string "website_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identification_url"
    t.string "cgvu_url"
    t.string "data_privacy_url"
    t.string "cookie_system_url"
    t.index ["user_id"], name: "index_analyses_on_user_id"
  end

  create_table "cgvus", force: :cascade do |t|
    t.bigint "analysis_id"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_cgvus_on_analysis_id"
  end

  create_table "cookie_systems", force: :cascade do |t|
    t.bigint "analysis_id"
    t.boolean "cookie_usage"
    t.boolean "cookie_user_agreement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_cookie_systems_on_analysis_id"
  end

  create_table "data_privacies", force: :cascade do |t|
    t.bigint "analysis_id"
    t.boolean "presence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_data_privacies_on_analysis_id"
  end

  create_table "identifications", force: :cascade do |t|
    t.bigint "analysis_id"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_identifications_on_analysis_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "analyses", "users"
  add_foreign_key "cgvus", "analyses"
  add_foreign_key "cookie_systems", "analyses"
  add_foreign_key "data_privacies", "analyses"
  add_foreign_key "identifications", "analyses"
end
