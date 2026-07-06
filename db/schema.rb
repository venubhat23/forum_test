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

ActiveRecord::Schema[8.0].define(version: 2026_07_06_013645) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.string "title", null: false
    t.text "body", null: false
    t.integer "audience", default: 0, null: false
    t.bigint "forum_id"
    t.bigint "plan_id"
    t.datetime "published_at"
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_announcements_on_created_by_id"
    t.index ["forum_id"], name: "index_announcements_on_forum_id"
    t.index ["plan_id"], name: "index_announcements_on_plan_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "event_type", null: false
    t.date "occurred_on", null: false
    t.boolean "present", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "meeting_id"
    t.index ["meeting_id"], name: "index_attendances_on_meeting_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "business_categories", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_business_categories_on_forum_id"
    t.index ["parent_id"], name: "index_business_categories_on_parent_id"
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

  create_table "coupons", force: :cascade do |t|
    t.string "code", null: false
    t.integer "discount_type", default: 0, null: false
    t.decimal "discount_value", precision: 10, scale: 2, null: false
    t.boolean "active", default: true, null: false
    t.date "expires_on"
    t.integer "max_redemptions"
    t.integer "times_redeemed", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_coupons_on_code", unique: true
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

  create_table "forum_requests", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "company_name", null: false
    t.text "message"
    t.integer "status", default: 0, null: false
    t.text "review_note"
    t.bigint "reviewed_by_id"
    t.bigint "forum_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_forum_requests_on_forum_id"
    t.index ["reviewed_by_id"], name: "index_forum_requests_on_reviewed_by_id"
  end

  create_table "forums", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "status", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "plan_id", null: false
    t.datetime "started_at"
    t.datetime "trial_ends_at"
    t.date "renews_on"
    t.index ["plan_id"], name: "index_forums_on_plan_id"
    t.index ["slug"], name: "index_forums_on_slug", unique: true
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.bigint "plan_id"
    t.bigint "coupon_id"
    t.string "invoice_number", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "currency", default: "INR", null: false
    t.integer "status", default: 0, null: false
    t.date "due_date", null: false
    t.date "paid_on"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coupon_id"], name: "index_invoices_on_coupon_id"
    t.index ["forum_id"], name: "index_invoices_on_forum_id"
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["plan_id"], name: "index_invoices_on_plan_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.integer "meeting_type", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.string "venue"
    t.string "speaker"
    t.text "agenda"
    t.text "minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_meetings_on_chapter_id"
  end

  create_table "office_darshans", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.bigint "member_id", null: false
    t.date "visit_date", null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_office_darshans_on_forum_id"
    t.index ["member_id"], name: "index_office_darshans_on_member_id"
  end

  create_table "one_to_one_meetings", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.bigint "requester_id", null: false
    t.bigint "requested_with_id", null: false
    t.datetime "scheduled_at", null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.date "follow_up_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_one_to_one_meetings_on_forum_id"
    t.index ["requested_with_id"], name: "index_one_to_one_meetings_on_requested_with_id"
    t.index ["requester_id"], name: "index_one_to_one_meetings_on_requester_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "payment_method", default: 0, null: false
    t.date "paid_on", null: false
    t.string "reference_number"
    t.bigint "recorded_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_payments_on_invoice_id"
    t.index ["recorded_by_id"], name: "index_payments_on_recorded_by_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "billing_cycle", default: 0, null: false
    t.integer "member_limit"
    t.text "features", default: [], null: false, array: true
    t.integer "trial_days", default: 14, null: false
    t.integer "status", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_plans_on_key", unique: true
  end

  create_table "platform_settings", force: :cascade do |t|
    t.string "site_name", default: "Krama Consultancy", null: false
    t.string "support_email"
    t.string "currency", default: "INR", null: false
    t.string "invoice_prefix", default: "INV", null: false
    t.decimal "tax_percent", precision: 5, scale: 2, default: "0.0", null: false
    t.bigint "default_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["default_plan_id"], name: "index_platform_settings_on_default_plan_id"
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

  create_table "support_ticket_replies", force: :cascade do |t|
    t.bigint "support_ticket_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["support_ticket_id"], name: "index_support_ticket_replies_on_support_ticket_id"
    t.index ["user_id"], name: "index_support_ticket_replies_on_user_id"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.bigint "forum_id"
    t.bigint "raised_by_id", null: false
    t.string "subject", null: false
    t.text "body", null: false
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_support_tickets_on_forum_id"
    t.index ["raised_by_id"], name: "index_support_tickets_on_raised_by_id"
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
    t.string "session_token", null: false
    t.datetime "suspended_at"
    t.string "gst_number"
    t.string "pan_number"
    t.string "aadhaar_number"
    t.string "website"
    t.text "address"
    t.integer "experience_years"
    t.date "date_of_birth"
    t.integer "membership_status", default: 0, null: false
    t.date "renews_on"
    t.bigint "business_category_id"
    t.datetime "converted_at"
    t.date "term_starts_on"
    t.date "term_ends_on"
    t.text "responsibilities"
    t.bigint "membership_plan_id"
    t.index ["business_category_id"], name: "index_users_on_business_category_id"
    t.index ["chapter_id"], name: "index_users_on_chapter_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["forum_id"], name: "index_users_on_forum_id"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["membership_plan_id"], name: "index_users_on_membership_plan_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weekly_presentations", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.bigint "member_id", null: false
    t.bigint "meeting_id"
    t.string "topic", null: false
    t.date "scheduled_on", null: false
    t.text "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_weekly_presentations_on_chapter_id"
    t.index ["meeting_id"], name: "index_weekly_presentations_on_meeting_id"
    t.index ["member_id"], name: "index_weekly_presentations_on_member_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "announcements", "forums"
  add_foreign_key "announcements", "plans"
  add_foreign_key "announcements", "users", column: "created_by_id"
  add_foreign_key "attendances", "meetings"
  add_foreign_key "attendances", "users"
  add_foreign_key "business_categories", "business_categories", column: "parent_id"
  add_foreign_key "business_categories", "forums"
  add_foreign_key "chapters", "forums"
  add_foreign_key "fee_payments", "users"
  add_foreign_key "forum_requests", "forums"
  add_foreign_key "forum_requests", "users", column: "reviewed_by_id"
  add_foreign_key "forums", "plans"
  add_foreign_key "invoices", "coupons"
  add_foreign_key "invoices", "forums"
  add_foreign_key "invoices", "plans"
  add_foreign_key "meetings", "chapters"
  add_foreign_key "office_darshans", "forums"
  add_foreign_key "office_darshans", "users", column: "member_id"
  add_foreign_key "one_to_one_meetings", "forums"
  add_foreign_key "one_to_one_meetings", "users", column: "requested_with_id"
  add_foreign_key "one_to_one_meetings", "users", column: "requester_id"
  add_foreign_key "payments", "invoices"
  add_foreign_key "payments", "users", column: "recorded_by_id"
  add_foreign_key "platform_settings", "plans", column: "default_plan_id"
  add_foreign_key "referrals", "users", column: "giver_id"
  add_foreign_key "referrals", "users", column: "receiver_id"
  add_foreign_key "support_ticket_replies", "support_tickets"
  add_foreign_key "support_ticket_replies", "users"
  add_foreign_key "support_tickets", "forums"
  add_foreign_key "support_tickets", "users", column: "raised_by_id"
  add_foreign_key "thanksgiving_slips", "referrals"
  add_foreign_key "thanksgiving_slips", "users", column: "given_by_id"
  add_foreign_key "users", "business_categories"
  add_foreign_key "users", "chapters"
  add_foreign_key "users", "forums"
  add_foreign_key "users", "users", column: "invited_by_id"
  add_foreign_key "weekly_presentations", "chapters"
  add_foreign_key "weekly_presentations", "meetings"
  add_foreign_key "weekly_presentations", "users", column: "member_id"
end
