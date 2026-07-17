module FeePaymentsHelper
  # Builds a wa.me click-to-chat link with a pre-filled fee reminder for a
  # specific event/meeting/training, as opposed to the annual membership fee
  # reminder in MembersHelper.
  def whatsapp_item_fee_reminder_link(person, fee, subject, forum)
    whatsapp_link(person.phone, whatsapp_item_fee_reminder_message(person, fee, subject, forum))
  end

  def whatsapp_item_fee_reminder_message(person, fee, subject, forum)
    amount_text = fee ? " of #{number_to_currency(fee.balance_due)}" : ""

    <<~MSG.strip
      Hi #{person.display_name}! 👋

      This is a friendly reminder from #{forum.name} that your fee#{amount_text} for *#{subject}* is still pending.

      Kindly complete the payment at your earliest convenience.

      Thank you! 🙏
    MSG
  end
end
