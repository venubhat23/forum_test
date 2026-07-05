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

ActiveRecord::Schema[8.0].define(version: 2026_07_05_104538) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "event_type", null: false
    t.date "occurred_on", null: false
    t.boolean "present", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id", "name"], name: "index_chapters_on_forum_id_and_name", unique: true
    t.index ["forum_id"], name: "index_chapters_on_forum_id"
  end

  create_table "fee_payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "fee_type", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "status", default: 0, null: false
    t.date "due_date"
    t.date "paid_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_fee_payments_on_user_id"
  end

  create_table "forums", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "status", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "plan", default: 0, null: false
    t.index ["slug"], name: "index_forums_on_slug", unique: true
  end

  create_table "referrals", force: :cascade do |t|
    t.bigint "giver_id", null: false
    t.bigint "receiver_id", null: false
    t.integer "referral_type", null: false
    t.string "prospect_name", null: false
    t.string "prospect_phone"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["giver_id"], name: "index_referrals_on_giver_id"
    t.index ["receiver_id"], name: "index_referrals_on_receiver_id"
  end

  create_table "thanksgiving_slips", force: :cascade do |t|
    t.bigint "referral_id", null: false
    t.bigint "given_by_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["given_by_id"], name: "index_thanksgiving_slips_on_given_by_id"
    t.index ["referral_id"], name: "index_thanksgiving_slips_on_referral_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 4, null: false
    t.bigint "forum_id"
    t.bigint "chapter_id"
    t.string "full_name"
    t.string "phone"
    t.string "business_name"
    t.string "business_category"
    t.string "speciality"
    t.string "nature_of_business"
    t.bigint "invited_by_id"
    t.string "designation"
    t.index ["chapter_id"], name: "index_users_on_chapter_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["forum_id"], name: "index_users_on_forum_id"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "attendances", "users"
  add_foreign_key "chapters", "forums"
  add_foreign_key "fee_payments", "users"
  add_foreign_key "referrals", "users", column: "giver_id"
  add_foreign_key "referrals", "users", column: "receiver_id"
  add_foreign_key "thanksgiving_slips", "referrals"
  add_foreign_key "thanksgiving_slips", "users", column: "given_by_id"
  add_foreign_key "users", "chapters"
  add_foreign_key "users", "forums"
  add_foreign_key "users", "users", column: "invited_by_id"
end
