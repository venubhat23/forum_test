module MembersHelper
  # Renders an inline SVG QR code that opens the member sign-in page when
  # scanned. Since there's no member mobile app, this is how a member gets
  # from their phone camera straight to the portal — printed on their ID
  # card — instead of typing a URL by hand.
  def member_login_qr_code_svg(size: 4)
    RQRCode::QRCode.new(new_user_session_url).as_svg(
      offset: size * 4,
      fill: "ffffff",
      color: "1e293b",
      shape_rendering: "crispEdges",
      module_size: size,
      standalone: true,
      use_path: true,
      viewbox: true
    ).html_safe
  end

  # Renewal date chip text for a member row: "Renews ..." while current,
  # flips to "Expired ..." once the date has passed (lifetime members never
  # reach here since callers check lifetime_member? first).
  def renewal_status_text(member)
    return "Renewal not set" if member.renews_on.blank?

    date_text = member.renews_on.strftime("%d %b %Y")
    member.membership_expired? ? "Expired #{date_text}" : "Renews #{date_text}"
  end

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
