module InvoicesHelper
  INVOICE_STATUS_BADGE_CLASSES = {
    "draft" => "badge-status-expired",
    "pending" => "badge-status-trial",
    "paid" => "badge-status-active",
    "overdue" => "badge-status-suspended",
    "cancelled" => "badge-status-expired",
    "partially_paid" => "badge-status-partial"
  }.freeze

  def invoice_status_badge_class(invoice)
    INVOICE_STATUS_BADGE_CLASSES.fetch(invoice.status, "badge-status-expired")
  end

  # Builds a wa.me click-to-chat link with a pre-filled message sharing the
  # invoice's public link, addressed to the billed forum's admin.
  def whatsapp_invoice_share_link(invoice)
    admin = invoice.forum.users.find_by(role: :forum_admin)
    whatsapp_link(admin&.phone, whatsapp_invoice_share_message(invoice))
  end

  def whatsapp_invoice_share_message(invoice)
    <<~MSG.strip
      Hi #{invoice.forum.name}! 👋

      Here's your invoice *#{invoice.invoice_number}* for #{number_to_currency(invoice.amount, unit: '₹', format: '%u%n')}, due by *#{invoice.due_date.strftime('%d %b %Y')}*.

      View & pay: #{public_invoice_url(invoice.share_token)}

      Thank you! 🙏
    MSG
  end
end
