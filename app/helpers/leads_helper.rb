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
    key = "lead_update_#{lead.stage}"
    key = "lead_update_default" unless WhatsappTemplate::FORUM_KEYS.include?(key)

    vars = { created_by_name: lead.created_by.display_name, prospect_name: lead.prospect_name, who: who }
    vars[:stage_label] = lead_stage_label(lead.stage)
    vars[:amount_text] = lead.thanksgiving_amount ? " of #{number_to_currency(lead.thanksgiving_amount)}" : ""

    WhatsappTemplate.render(lead.forum, key, vars)
  end

  # Nudge a tagged member (who hasn't claimed yet) to log in and accept the lead.
  def whatsapp_lead_request_link(lead, member)
    whatsapp_link(member.phone, whatsapp_lead_request_message(lead, member))
  end

  def whatsapp_lead_request_message(lead, member)
    business_text = lead.business_name.present? ? " at #{lead.business_name}" : ""

    WhatsappTemplate.render(lead.forum, :lead_request,
      display_name: member.display_name, created_by_name: lead.created_by.display_name,
      prospect_name: lead.prospect_name, business_text: business_text)
  end
end
