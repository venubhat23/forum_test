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

ActiveRecord::Schema[8.0].define(version: 2026_07_21_050000) do
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

  create_table "events", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.string "title", null: false
    t.integer "event_type", default: 0, null: false
    t.datetime "starts_at", null: false
    t.string "venue"
    t.datetime "registration_opens_at"
    t.datetime "registration_closes_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "chapter_id"
    t.text "description"
    t.bigint "created_by_id"
    t.decimal "fee_amount", precision: 10, scale: 2
    t.string "payment_upi_id"
    t.text "payment_bank_details"
    t.string "speaker"
    t.string "speaker_phone"
    t.index ["chapter_id"], name: "index_events_on_chapter_id"
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["forum_id"], name: "index_events_on_forum_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.string "category", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "incurred_on", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "expenseable_type"
    t.bigint "expenseable_id"
    t.index ["expenseable_type", "expenseable_id"], name: "index_expenses_on_expenseable"
    t.index ["forum_id"], name: "index_expenses_on_forum_id"
  end

  create_table "fee_payment_transactions", force: :cascade do |t|
    t.bigint "fee_payment_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "payment_method"
    t.date "paid_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fee_payment_id"], name: "index_fee_payment_transactions_on_fee_payment_id"
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
    t.string "invoice_number", null: false
    t.integer "payment_method"
    t.string "feeable_type"
    t.bigint "feeable_id"
    t.integer "duration_years"
    t.boolean "lifetime", default: false, null: false
    t.index ["feeable_type", "feeable_id"], name: "index_fee_payments_on_feeable"
    t.index ["invoice_number"], name: "index_fee_payments_on_invoice_number", unique: true
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
    t.bigint "business_plan_id"
    t.index ["business_plan_id"], name: "index_forum_requests_on_business_plan_id"
    t.index ["forum_id"], name: "index_forum_requests_on_forum_id"
    t.index ["reviewed_by_id"], name: "index_forum_requests_on_reviewed_by_id"
  end

  create_table "forum_settings", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.string "theme_color", default: "#4f46e5"
    t.string "invoice_prefix", default: "INV"
    t.text "attendance_rules"
    t.text "meeting_rules"
    t.text "membership_rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_forum_settings_on_forum_id", unique: true
  end

  create_table "forums", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.integer "status", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "plan_id"
    t.datetime "started_at"
    t.datetime "trial_ends_at"
    t.date "renews_on"
    t.bigint "business_plan_id"
    t.datetime "suspended_at"
    t.index ["business_plan_id"], name: "index_forums_on_business_plan_id"
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
    t.string "share_token"
    t.bigint "user_id"
    t.index ["coupon_id"], name: "index_invoices_on_coupon_id"
    t.index ["forum_id"], name: "index_invoices_on_forum_id"
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true
    t.index ["plan_id"], name: "index_invoices_on_plan_id"
    t.index ["share_token"], name: "index_invoices_on_share_token", unique: true
    t.index ["user_id"], name: "index_invoices_on_user_id"
  end

  create_table "lead_taggings", force: :cascade do |t|
    t.bigint "lead_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id", "user_id"], name: "index_lead_taggings_on_lead_id_and_user_id", unique: true
    t.index ["lead_id"], name: "index_lead_taggings_on_lead_id"
    t.index ["user_id"], name: "index_lead_taggings_on_user_id"
  end

  create_table "leads", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.bigint "created_by_id", null: false
    t.bigint "accepted_by_id"
    t.string "prospect_name", null: false
    t.string "prospect_phone"
    t.string "prospect_email"
    t.string "business_name"
    t.string "business_category"
    t.text "requirement"
    t.text "notes"
    t.integer "stage", default: 0, null: false
    t.datetime "accepted_at"
    t.decimal "thanksgiving_amount", precision: 10, scale: 2
    t.text "thanksgiving_notes"
    t.datetime "thanksgiving_given_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_by_id"], name: "index_leads_on_accepted_by_id"
    t.index ["created_by_id"], name: "index_leads_on_created_by_id"
    t.index ["forum_id"], name: "index_leads_on_forum_id"
  end

  create_table "meeting_schedule_attendees", force: :cascade do |t|
    t.bigint "meeting_schedule_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meeting_schedule_id", "user_id"], name: "index_schedule_attendees_on_schedule_and_user", unique: true
    t.index ["meeting_schedule_id"], name: "index_meeting_schedule_attendees_on_meeting_schedule_id"
    t.index ["user_id"], name: "index_meeting_schedule_attendees_on_user_id"
  end

  create_table "meeting_schedules", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.bigint "created_by_id", null: false
    t.string "title"
    t.integer "day_of_week", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "venue"
    t.text "agenda"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "fee_amount", precision: 10, scale: 2
    t.index ["chapter_id"], name: "index_meeting_schedules_on_chapter_id"
    t.index ["created_by_id"], name: "index_meeting_schedules_on_created_by_id"
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
    t.decimal "fee_amount", precision: 10, scale: 2
    t.string "payment_upi_id"
    t.text "payment_bank_details"
    t.bigint "meeting_schedule_id"
    t.string "speaker_phone"
    t.index ["chapter_id"], name: "index_meetings_on_chapter_id"
    t.index ["meeting_schedule_id"], name: "index_meetings_on_meeting_schedule_id"
  end

  create_table "membership_applications", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.bigint "chapter_id"
    t.bigint "event_id"
    t.bigint "invited_by_id"
    t.bigint "reviewed_by_id"
    t.bigint "user_id"
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "company_name"
    t.string "designation"
    t.string "pan_number"
    t.string "gst_number"
    t.text "business_address"
    t.integer "source", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.string "token", null: false
    t.text "payment_instructions"
    t.text "review_note"
    t.integer "feedback_rating"
    t.text "feedback_comment"
    t.datetime "confirmed_at"
    t.datetime "attended_at"
    t.datetime "feedback_collected_at"
    t.datetime "join_invite_sent_at"
    t.datetime "interested_at"
    t.datetime "kyc_submitted_at"
    t.datetime "review_started_at"
    t.datetime "approved_at"
    t.datetime "rejected_at"
    t.datetime "paid_at"
    t.datetime "member_since_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_membership_applications_on_chapter_id"
    t.index ["event_id"], name: "index_membership_applications_on_event_id"
    t.index ["forum_id"], name: "index_membership_applications_on_forum_id"
    t.index ["invited_by_id"], name: "index_membership_applications_on_invited_by_id"
    t.index ["reviewed_by_id"], name: "index_membership_applications_on_reviewed_by_id"
    t.index ["status"], name: "index_membership_applications_on_status"
    t.index ["token"], name: "index_membership_applications_on_token", unique: true
    t.index ["user_id"], name: "index_membership_applications_on_user_id"
  end

  create_table "membership_plans", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.string "name", null: false
    t.integer "cycle", default: 0, null: false
    t.decimal "price", precision: 10, scale: 2, default: "0.0", null: false
    t.text "renewal_rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_membership_plans_on_forum_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "body", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "office_darshans", force: :cascade do |t|
    t.bigint "forum_id", null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "host_id", null: false
    t.bigint "visitor_id", null: false
    t.datetime "scheduled_at", null: false
    t.datetime "confirmed_at"
    t.datetime "thanked_at"
    t.index ["forum_id"], name: "index_office_darshans_on_forum_id"
    t.index ["host_id"], name: "index_office_darshans_on_host_id"
    t.index ["visitor_id"], name: "index_office_darshans_on_visitor_id"
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
    t.decimal "fee_amount", precision: 10, scale: 2
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

  create_table "permissions", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "module_name", limit: 50, null: false
    t.string "action_type", limit: 20, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_permissions_on_action_type"
    t.index ["module_name", "action_type"], name: "index_permissions_on_module_name_and_action_type", unique: true
    t.index ["module_name"], name: "index_permissions_on_module_name"
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
    t.integer "chapter_limit"
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
    t.bigint "forum_id", null: false
    t.bigint "chapter_id"
    t.bigint "referrer_id", null: false
    t.bigint "referred_user_id", null: false
    t.text "business_context", null: false
    t.string "contact_name"
    t.string "contact_phone"
    t.integer "status", default: 0, null: false
    t.datetime "accepted_at"
    t.datetime "in_progress_at"
    t.datetime "converted_at"
    t.datetime "rejected_at"
    t.text "rejection_note"
    t.datetime "thanked_at"
    t.text "thank_you_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id"], name: "index_referrals_on_chapter_id"
    t.index ["forum_id"], name: "index_referrals_on_forum_id"
    t.index ["referred_user_id"], name: "index_referrals_on_referred_user_id"
    t.index ["referrer_id"], name: "index_referrals_on_referrer_id"
    t.index ["status"], name: "index_referrals_on_status"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "idx_role_permissions_permission"
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "idx_role_permissions_unique", unique: true
    t.index ["role_id"], name: "idx_role_permissions_role"
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description"
    t.boolean "status", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
    t.index ["status"], name: "index_roles_on_status"
  end

  create_table "session_activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "activity_type"
    t.datetime "occurred_at"
    t.string "ip_address"
    t.text "user_agent"
    t.string "session_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_session_activities_on_user_id"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

