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
    return nil if invoice.share_token.blank?

    admin = invoice.forum.users.find_by(role: :forum_admin)
    whatsapp_link(admin&.phone, whatsapp_invoice_share_message(invoice))
  end

  def whatsapp_invoice_share_message(invoice)
    WhatsappTemplate.render(nil, :invoice_share,
      forum_name: invoice.forum.name, invoice_number: invoice.invoice_number,
      amount: number_to_currency(invoice.amount, unit: "₹", format: "%u%n"),
      due_date: invoice.due_date.strftime("%d %b %Y"), invoice_url: public_invoice_url(invoice.share_token))
  end

  # Builds a wa.me click-to-chat link sharing a member invoice's public link,
  # addressed to the billed member directly (as opposed to the forum admin
  # link above, which is used for platform-level invoices).
  def whatsapp_member_invoice_share_link(invoice)
    return nil if invoice.share_token.blank? || invoice.user.blank?

    whatsapp_link(invoice.user.phone, whatsapp_member_invoice_share_message(invoice))
  end

  def whatsapp_member_invoice_share_message(invoice)
    WhatsappTemplate.render(invoice.forum, :member_invoice_share,
      display_name: invoice.user.display_name, forum_name: invoice.forum.name, invoice_number: invoice.invoice_number,
      amount: number_to_currency(invoice.amount, unit: "₹", format: "%u%n"),
      due_date: invoice.due_date.strftime("%d %b %Y"), invoice_url: public_invoice_url(invoice.share_token))
  end

  def invoice_brand_name(invoice)
    invoice.member_invoice? ? invoice.forum.name : "Krama Consultancy"
  end

  def invoice_brand_subtitle(invoice)
    invoice.member_invoice? ? "Membership Billing" : "Business Network Forum Platform"
  end

  # Neither Krama Consultancy nor individual forums have an uploaded logo file
  # to put on an invoice document, so invoices carry this inline SVG monogram
  # instead of an <img> — crisp in print/PDF with no asset dependency.
  def invoice_logo_svg(name, size: 64)
    initials = name.to_s.split(/\s+/).reject(&:blank?).first(2).map { |w| w[0].upcase }.join
    initials = "?" if initials.blank?
    gradient_id = "invoiceLogoGradient#{size}#{initials.hash.abs}"

    <<~SVG.html_safe
      <svg class="invoice-logo-mark" width="#{size}" height="#{size}" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="#{ERB::Util.html_escape(name)}">
        <defs>
          <linearGradient id="#{gradient_id}" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stop-color="#3b82f6"/>
            <stop offset="100%" stop-color="#8b5cf6"/>
          </linearGradient>
        </defs>
        <circle cx="32" cy="32" r="31" fill="url(##{gradient_id})"/>
        <text x="32" y="41" text-anchor="middle" font-family="Arial, sans-serif" font-size="#{initials.length > 1 ? 22 : 26}" font-weight="700" fill="#ffffff">#{ERB::Util.html_escape(initials)}</text>
      </svg>
    SVG
  end

  ONES = %w[Zero One Two Three Four Five Six Seven Eight Nine Ten
            Eleven Twelve Thirteen Fourteen Fifteen Sixteen Seventeen Eighteen Nineteen].freeze
  TENS = %w[Zero Ten Twenty Thirty Forty Fifty Sixty Seventy Eighty Ninety].freeze

  # Spells out a rupee amount using the Indian numbering system
  # (Crore / Lakh / Thousand / Hundred), e.g. "One Lakh Twenty Three Thousand Rupees Only".
  def invoice_amount_in_words(amount)
    whole = amount.to_i
    return "Zero Rupees Only" if whole.zero?

    parts = []
    crore, whole = whole.divmod(1_00_00_000)
    parts << "#{amount_group_in_words(crore)} Crore" if crore.positive?
    lakh, whole = whole.divmod(1_00_000)
    parts << "#{amount_group_in_words(lakh)} Lakh" if lakh.positive?
    thousand, whole = whole.divmod(1_000)
    parts << "#{amount_group_in_words(thousand)} Thousand" if thousand.positive?
    parts << amount_group_in_words(whole) if whole.positive?

    "#{parts.join(' ')} Rupees Only"
  end

  private

  # Converts a number under 1000 into words.
  def amount_group_in_words(number)
    return "" if number.zero?

    words = []
    hundreds, remainder = number.divmod(100)
    words << "#{ONES[hundreds]} Hundred" if hundreds.positive?

    if remainder.positive?
      if remainder < 20
        words << ONES[remainder]
      else
        tens, ones = remainder.divmod(10)
        words << (ones.positive? ? "#{TENS[tens]} #{ONES[ones]}" : TENS[tens])
      end
    end

    words.join(" ")
  end
end
