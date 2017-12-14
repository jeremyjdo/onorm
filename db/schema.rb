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

ActiveRecord::Schema.define(version: 20171213094155) do

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
    t.boolean "service_presence"
    t.string "service_article_ref"
    t.boolean "service_access_presence"
    t.boolean "service_description_presence"
    t.boolean "delivery_presence"
    t.string "delivery_article_ref"
    t.boolean "delivery_modality_presence"
    t.boolean "delivery_shipping_presence"
    t.boolean "delivery_time_presence"
    t.boolean "price_presence"
    t.string "price_article_ref"
    t.boolean "price_euro_currency_presence"
    t.boolean "price_ttc_presence"
    t.boolean "price_mention_presence"
    t.boolean "payment_presence"
    t.string "payment_article_ref"
    t.boolean "payment_mention_presence"
    t.boolean "retractation_presence"
    t.string "retractation_article_ref"
    t.boolean "retractation_right_presence"
    t.boolean "contract_conclusion_presence"
    t.string "contract_conclusion_article_ref"
    t.boolean "contract_conclusion_modality_presence"
    t.boolean "contract_conclusion_agreement_presence"
    t.boolean "contract_conclusion_human_error_presence"
    t.boolean "contract_conclusion_offer_durability_presence"
    t.boolean "guaranteeandsav_presence"
    t.string "guaranteeandsav_article_ref"
    t.boolean "guaranteeandsav_guarantee_presence"
    t.boolean "guaranteeandsav_sav_presence"
    t.index ["analysis_id"], name: "index_cgvus_on_analysis_id"
  end

  create_table "cookie_systems", force: :cascade do |t|
    t.bigint "analysis_id"
    t.boolean "cookie_usage"
    t.boolean "cookie_user_agreement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "score"
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
    t.float "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "company_name_presence"
    t.boolean "legal_form_presence"
    t.text "legal_form_text"
    t.boolean "address_presence"
    t.text "address_text"
    t.boolean "capital_presence"
    t.text "capital_text"
    t.boolean "email_presence"
    t.text "email_text"
    t.boolean "phone_presence"
    t.text "phone_text"
    t.boolean "publication_director_presence"
    t.text "publication_director_text"
    t.boolean "rcs_presence"
    t.text "rcs_text"
    t.boolean "tva_presence"
    t.text "tva_text"
    t.boolean "host_name_presence"
    t.boolean "host_address_presence"
    t.boolean "host_phone_presence"
    t.text "host_text"
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
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "analyses", "users"
  add_foreign_key "cgvus", "analyses"
  add_foreign_key "cookie_systems", "analyses"
  add_foreign_key "data_privacies", "analyses"
  add_foreign_key "identifications", "analyses"
end
