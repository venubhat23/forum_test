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

ActiveRecord::Schema[8.0].define(version: 2026_08_01_000000) do
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
    t.bigint "chapter_id"
    t.bigint "target_user_id"
    t.index ["chapter_id"], name: "index_announcements_on_chapter_id"
    t.index ["created_by_id"], name: "index_announcements_on_created_by_id"
    t.index ["forum_id"], name: "index_announcements_on_forum_id"
    t.index ["plan_id"], name: "index_announcements_on_plan_id"
    t.index ["target_user_id"], name: "index_announcements_on_target_user_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "event_type", null: false
    t.date "occurred_on", null: false
    t.boolean "present", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "meeting_id"
    t.bigint "event_id"
    t.integer "status", default: 0, null: false
    t.index ["event_id"], name: "index_attendances_on_event_id"
    t.index ["meeting_id"], name: "index_attendances_on_meeting_id"
    t.index ["user_id", "event_id"], name: "index_attendances_on_user_id_and_event_id", unique: true
    t.index ["user_id", "meeting_id"], name: "index_attendances_on_user_id_and_meeting_id", unique: true
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "badges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "key", null: false
    t.date "period", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "key", "period"], name: "index_badges_on_user_id_and_key_and_period", unique: true
    t.index ["user_id"], name: "index_badges_on_user_id"
  end

  create_table "banner_documents", force: :cascade do |t|
    t.bigint "banner_id", null: false
    t.string "document_type"
    t.string "title"
    t.text "description"
    t.string "r2_file_key"
    t.string "r2_filename"
    t.string "r2_content_type"
    t.bigint "r2_file_size"
    t.string "uploaded_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["banner_id"], name: "index_banner_documents_on_banner_id"
  end

  create_table "banners", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "redirect_link"
    t.date "display_start_date"
    t.date "display_end_date"
    t.string "display_location"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "display_order", default: 0
    t.string "r2_file_key"
    t.string "r2_filename"
    t.string "r2_content_type"
    t.bigint "r2_file_size"
    t.text "r2_public_url"
    t.index ["display_order"], name: "index_banners_on_display_order"
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

  create_table "business_plans", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "chapter_limit"
    t.integer "member_limit"
    t.text "description"
    t.boolean "active", default: true, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_business_plans_on_key", unique: true
  end

  create_table "chapters", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.string "name", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "annual_membership_fee", precision: 10, scale: 2
    t.decimal "lifetime_membership_fee", precision: 10, scale: 2
    t.decimal "monthly_membership_fee", precision: 10, scale: 2
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

  create_table "documents", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.string "title", null: false
    t.string "category"
    t.string "documentable_type"
    t.bigint "documentable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable"
    t.index ["forum_id"], name: "index_documents_on_forum_id"
  end

  create_table "event_registrations", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "user_id"
    t.boolean "attended", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rsvp_status", default: 0, null: false
    t.datetime "attended_at"
    t.string "guest_name"
    t.string "guest_email"
    t.bigint "invited_by_id"
    t.string "guest_phone"
    t.string "token"
    t.boolean "thanked", default: false, null: false
    t.datetime "thanked_at"
    t.index ["event_id", "user_id"], name: "index_event_registrations_on_event_id_and_user_id", unique: true
    t.index ["event_id"], name: "index_event_registrations_on_event_id"
    t.index ["invited_by_id"], name: "index_event_registrations_on_invited_by_id"
    t.index ["rsvp_status"], name: "index_event_registrations_on_rsvp_status"
    t.index ["token"], name: "index_event_registrations_on_token", unique: true
    t.index ["user_id"], name: "index_event_registrations_on_user_id"
  end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              