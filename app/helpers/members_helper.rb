module MembersHelper
  # Builds a wa.me click-to-chat link that opens WhatsApp with a pre-filled
  # annual membership fee reminder for the given member.
  def whatsapp_fee_reminder_link(member, fee, forum)
    whatsapp_link(member.phone, whatsapp_fee_reminder_message(member, fee, forum))
  end

  def whatsapp_fee_reminder_message(member, fee, forum)
    amount_text = fee ? " of #{number_to_currency(fee.balance_due)}" : ""
    due_text = fee&.due_date ? " by *#{fee.due_date.strftime('%d %b %Y')}*" : ""

    WhatsappTemplate.render(forum, :fee_reminder_annual,
      display_name: member.display_name, forum_name: forum.name,
      amount_text: amount_text, due_text: due_text)
  end

  # Builds a wa.me click-to-chat link with a congratulatory welcome message,
  # sent once a newly converted member's membership fee has been paid.
  def whatsapp_welcome_link(member, forum)
    whatsapp_link(member.phone, whatsapp_welcome_message(member, forum))
  end

  def whatsapp_welcome_message(member, forum)
    validity_text = member.lifetime_member? ? "a *lifetime member*" : "a member until *#{member.renews_on&.strftime('%d %b %Y')}*"

    WhatsappTemplate.render(forum, :welcome,
      display_name: member.display_name, validity_text: validity_text, forum_name: forum.name,
      chapter_name: member.chapter&.name, business_name: member.business_name.presence || "your business")
  end
end
