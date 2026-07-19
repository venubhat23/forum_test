module MembersHelper
  # Builds a wa.me click-to-chat link that opens WhatsApp with a pre-filled
  # annual membership fee reminder for the given member.
  def whatsapp_fee_reminder_link(member, fee, forum)
    whatsapp_link(member.phone, whatsapp_fee_reminder_message(member, fee, forum))
  end

  def whatsapp_fee_reminder_message(member, fee, forum)
    amount_text = fee ? " of #{number_to_currency(fee.balance_due)}" : ""
    due_text = fee&.due_date ? " by *#{fee.due_date.strftime('%d %b %Y')}*" : ""

    <<~MSG.strip
      Hi #{member.display_name}! 👋

      This is a friendly reminder from #{forum.name} that your *annual membership fee*#{amount_text} is due#{due_text}.

      Kindly complete the payment at your earliest convenience to keep your membership active without interruption.

      Thank you! 🙏
    MSG
  end

  # Builds a wa.me click-to-chat link with a congratulatory welcome message,
  # sent once a newly converted member's membership fee has been paid.
  def whatsapp_welcome_link(member, forum)
    whatsapp_link(member.phone, whatsapp_welcome_message(member, forum))
  end

  def whatsapp_welcome_message(member, forum)
    validity_text = member.lifetime_member? ? "a *lifetime member*" : "a member until *#{member.renews_on&.strftime('%d %b %Y')}*"

    <<~MSG.strip
      🎉 Congratulations #{member.display_name}! 🎊

      Your membership fee has been received and you are now officially #{validity_text} of #{forum.name}, #{member.chapter&.name} chapter!

      We're thrilled to have #{member.business_name.presence || "your business"} join our network. Welcome aboard, and here's to many great connections and referrals ahead! 🤝

      Warm regards,
      #{forum.name}
    MSG
  end
end
