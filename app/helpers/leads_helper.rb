module LeadsHelper
  STAGE_LABELS = {
    "requested" => "Requested",
    "accepted" => "Accepted",
    "consulting" => "Consulting",
    "doing_business" => "Doing Business",
    "converted" => "Converted",
    "declined" => "Declined"
  }.freeze

  STAGE_BADGE_CLASSES = {
    "requested" => "badge-status-trial",
    "accepted" => "badge-status-active",
    "consulting" => "badge-status-active",
    "doing_business" => "badge-status-active",
    "converted" => "bg-success",
    "declined" => "bg-secondary"
  }.freeze

  def lead_stage_label(stage)
    STAGE_LABELS[stage.to_s] || stage.to_s.titleize
  end

  def lead_stage_badge_class(stage)
    STAGE_BADGE_CLASSES[stage.to_s] || "bg-secondary"
  end

  # WhatsApp update from the member working the lead back to whoever created it.
  def whatsapp_lead_update_link(lead)
    whatsapp_link(lead.created_by.phone, whatsapp_lead_update_message(lead))
  end

  def whatsapp_lead_update_message(lead)
    who = lead.accepted_by&.display_name || "A member"

    case lead.stage
    when "accepted"
      "Hi #{lead.created_by.display_name}! 👋\n\nGood news — your lead for *#{lead.prospect_name}* was accepted by #{who}. They'll be in touch with the prospect soon.\n\nThanks for the referral! 🙌"
    when "consulting"
      "Hi #{lead.created_by.display_name}! 👋\n\nUpdate on your lead *#{lead.prospect_name}*: #{who} is now in the consulting stage with them."
    when "doing_business"
      "Hi #{lead.created_by.display_name}! 🎉\n\nUpdate on your lead *#{lead.prospect_name}*: #{who} has started doing business with them!"
    when "converted"
      amount_text = lead.thanksgiving_amount ? " of #{number_to_currency(lead.thanksgiving_amount)}" : ""
      "Hi #{lead.created_by.display_name}! 🙏\n\nYour lead for *#{lead.prospect_name}* has converted into business, and a Thanksgiving Slip#{amount_text} has been recorded in your name.\n\nWe truly appreciate the referral! 🎉"
    else
      "Hi #{lead.created_by.display_name}! 👋\n\nUpdate on your lead *#{lead.prospect_name}*: now at the #{lead_stage_label(lead.stage)} stage."
    end
  end

  # Nudge a tagged member (who hasn't claimed yet) to log in and accept the lead.
  def whatsapp_lead_request_link(lead, member)
    whatsapp_link(member.phone, whatsapp_lead_request_message(lead, member))
  end

  def whatsapp_lead_request_message(lead, member)
    business_text = lead.business_name.present? ? " at #{lead.business_name}" : ""

    "Hi #{member.display_name}! 👋\n\nYou have a new lead request from #{lead.created_by.display_name}: *#{lead.prospect_name}*#{business_text}.\n\nLog in and accept it before someone else does! 🚀"
  end
end
