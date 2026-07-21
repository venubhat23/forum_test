class WhatsappTemplate < ApplicationRecord
  belongs_to :forum, optional: true

  GLOBAL_KEYS = %w[invoice_share].freeze

  FORUM_KEYS = %w[
    welcome
    fee_reminder_annual
    fee_reminder_item
    event_invite
    speaker_invite
    schedule_invite
    lead_request
    lead_update_accepted
    lead_update_consulting
    lead_update_doing_business
    lead_update_converted
    lead_update_default
    darshan_thankyou_host
    darshan_thankyou_visitor
    fee_receipt_share
  ].freeze

  KEYS = (FORUM_KEYS + GLOBAL_KEYS).freeze

  LABELS = {
    "welcome" => "Member Welcome / Congratulations",
    "fee_reminder_annual" => "Annual Membership Fee Reminder",
    "fee_reminder_item" => "Event/Meeting Fee Reminder",
    "event_invite" => "Guest Event Invite",
    "speaker_invite" => "Guest Speaker Invite",
    "schedule_invite" => "Recurring Meeting Schedule Invite",
    "lead_request" => "Lead Request Nudge",
    "lead_update_accepted" => "Lead Update — Accepted",
    "lead_update_consulting" => "Lead Update — Consulting",
    "lead_update_doing_business" => "Lead Update — Doing Business",
    "lead_update_converted" => "Lead Update — Converted",
    "lead_update_default" => "Lead Update — Other Stages",
    "darshan_thankyou_host" => "Office Visit — Host Thanks Visitor",
    "darshan_thankyou_visitor" => "Office Visit — Visitor Thanks Host",
    "fee_receipt_share" => "Fee Receipt Share",
    "invoice_share" => "Platform Invoice Share"
  }.freeze

  VARIABLES = {
    "welcome" => %w[display_name validity_text forum_name chapter_name business_name],
    "fee_reminder_annual" => %w[display_name forum_name amount_text due_text],
    "fee_reminder_item" => %w[display_name forum_name amount_text subject],
    "event_invite" => %w[full_name event_title forum_name when_text venue_text],
    "speaker_invite" => %w[name subject forum_name when_text venue_text],
    "schedule_invite" => %w[display_name schedule_title forum_name when_text range_text venue_text agenda_text],
    "lead_request" => %w[display_name created_by_name prospect_name business_text],
    "lead_update_accepted" => %w[created_by_name prospect_name who],
    "lead_update_consulting" => %w[created_by_name prospect_name who],
    "lead_update_doing_business" => %w[created_by_name prospect_name who],
    "lead_update_converted" => %w[created_by_name prospect_name amount_text],
    "lead_update_default" => %w[created_by_name prospect_name stage_label],
    "darshan_thankyou_host" => %w[visitor_name scheduled_at],
    "darshan_thankyou_visitor" => %w[host_name scheduled_at],
    "fee_receipt_share" => %w[display_name invoice_number amount forum_name status_text],
    "invoice_share" => %w[forum_name invoice_number amount due_date invoice_url]
  }.freeze

  DEFAULTS = {
    "welcome" => <<~MSG.strip,
      🎉 Congratulations %{display_name}! 🎊

      Your membership fee has been received and you are now officially %{validity_text} of %{forum_name}, %{chapter_name} chapter!

      We're thrilled to have %{business_name} join our network. Welcome aboard, and here's to many great connections and referrals ahead! 🤝

      Warm regards,
      %{forum_name}
    MSG

    "fee_reminder_annual" => <<~MSG.strip,
      Hi %{display_name}! 👋

      This is a friendly reminder from %{forum_name} that your *annual membership fee*%{amount_text} is due%{due_text}.

      Kindly complete the payment at your earliest convenience to keep your membership active without interruption.

      Thank you! 🙏
    MSG

    "fee_reminder_item" => <<~MSG.strip,
      Hi %{display_name}! 👋

      This is a friendly reminder from %{forum_name} that your fee%{amount_text} for *%{subject}* is still pending.

      Kindly complete the payment at your earliest convenience.

      Thank you! 🙏
    MSG

    "event_invite" => <<~MSG.strip,
      Hi %{full_name}! 👋

      You're warmly invited to *%{event_title}*, hosted by %{forum_name}! 🎉

      🗓️ %{when_text}%{venue_text}

      We'd love to have you join us — come connect, network, and grow with us!

      See you there! 😊
    MSG

    "speaker_invite" => <<~MSG.strip,
      Hi %{name}! 👋

      We'd be honored to have you as our *guest speaker* for *%{subject}*, hosted by %{forum_name}! 🎤

      🗓️ %{when_text}%{venue_text}

      Please let us know if you're available — we'd love to have you with us!

      Thank you! 😊
    MSG

    "schedule_invite" => <<~MSG.strip,
      Hi %{display_name}! 👋

      You're invited to join *%{schedule_title}* at %{forum_name}! 🎉

      🗓️ %{when_text}
      📅 %{range_text}%{venue_text}%{agenda_text}

      Mark your calendar — we'd love to see you there every time! 😊
    MSG

    "lead_request" => <<~MSG.strip,
      Hi %{display_name}! 👋

      You have a new lead request from %{created_by_name}: *%{prospect_name}*%{business_text}.

      Log in and accept it before someone else does! 🚀
    MSG

    "lead_update_accepted" => <<~MSG.strip,
      Hi %{created_by_name}! 👋

      Good news — your lead for *%{prospect_name}* was accepted by %{who}. They'll be in touch with the prospect soon.

      Thanks for the referral! 🙌
    MSG

    "lead_update_consulting" => <<~MSG.strip,
      Hi %{created_by_name}! 👋

      Update on your lead *%{prospect_name}*: %{who} is now in the consulting stage with them.
    MSG

    "lead_update_doing_business" => <<~MSG.strip,
      Hi %{created_by_name}! 🎉

      Update on your lead *%{prospect_name}*: %{who} has started doing business with them!
    MSG

    "lead_update_converted" => <<~MSG.strip,
      Hi %{created_by_name}! 🙏

      Your lead for *%{prospect_name}* has converted into business, and a Thanksgiving Slip%{amount_text} has been recorded in your name.

      We truly appreciate the referral! 🎉
    MSG

    "lead_update_default" => <<~MSG.strip,
      Hi %{created_by_name}! 👋

      Update on your lead *%{prospect_name}*: now at the %{stage_label} stage.
    MSG

    "darshan_thankyou_host" => <<~MSG.strip,
      Hi %{visitor_name}! 🙏

      Thank you so much for visiting our office on %{scheduled_at}. It was wonderful hosting you — looking forward to more collaboration! 🤝
    MSG

    "darshan_thankyou_visitor" => <<~MSG.strip,
      Hi %{host_name}! 🙏

      Thank you for hosting me at your office on %{scheduled_at}. Really enjoyed the visit and looking forward to working together! 🤝
    MSG

    "fee_receipt_share" => <<~MSG.strip,
      Hi %{display_name}! Here is your membership fee invoice %{invoice_number} (%{amount}) from %{forum_name}. %{status_text}
    MSG

    "invoice_share" => <<~MSG.strip
      Hi %{forum_name}! 👋

      Here's your invoice *%{invoice_number}* for %{amount}, due by *%{due_date}*.

      View & pay: %{invoice_url}

      Thank you! 🙏
    MSG
  }.freeze

  validates :key, inclusion: { in: KEYS }
  validates :body, presence: true
  validates :key, uniqueness: { scope: :forum_id }

  # Looks up the forum's (or, for global keys, the platform's) saved override
  # and falls back to today's hardcoded wording when nothing has been customized.
  def self.resolve_body(forum, key)
    key = key.to_s
    scope = GLOBAL_KEYS.include?(key) ? where(forum_id: nil) : where(forum: forum)
    scope.find_by(key: key)&.body.presence || DEFAULTS.fetch(key)
  end

  # Renders a template with named %{var} placeholders. Uses a forgiving gsub
  # instead of String#% so a typo'd placeholder in an admin-edited template
  # can't raise KeyError and break the "send WhatsApp message" flow.
  def self.render(forum, key, vars = {})
    vars = vars.transform_keys(&:to_s)
    resolve_body(forum, key).gsub(/%\{(\w+)\}/) { vars.fetch($1, "") }
  end
end
