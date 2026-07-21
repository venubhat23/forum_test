module FeePaymentsHelper
  # Builds a wa.me click-to-chat link with a pre-filled fee reminder for a
  # specific event/meeting/training, as opposed to the annual membership fee
  # reminder in MembersHelper.
  def whatsapp_item_fee_reminder_link(person, fee, subject, forum)
    whatsapp_link(person.phone, whatsapp_item_fee_reminder_message(person, fee, subject, forum))
  end

  def whatsapp_item_fee_reminder_message(person, fee, subject, forum)
    amount_text = fee ? " of #{number_to_currency(fee.balance_due)}" : ""

    WhatsappTemplate.render(forum, :fee_reminder_item,
      display_name: person.display_name, forum_name: forum.name,
      amount_text: amount_text, subject: subject)
  end

  # Builds a wa.me click-to-chat link sharing a printable fee payment
  # invoice/receipt with the paying member.
  def whatsapp_receipt_share_link(member, fee_payment, forum)
    whatsapp_link(member.phone, whatsapp_receipt_share_message(member, fee_payment, forum))
  end

  def whatsapp_receipt_share_message(member, fee_payment, forum)
    status_text = fee_payment.paid? ? "Payment received with thanks! 🙏" : "Kindly complete the payment at your earliest convenience."

    WhatsappTemplate.render(forum, :fee_receipt_share,
      display_name: member.display_name, invoice_number: fee_payment.invoice_number,
      amount: number_to_currency(fee_payment.amount), forum_name: forum.name, status_text: status_text)
  end
end
