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
end
