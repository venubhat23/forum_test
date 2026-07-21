module WhatsappHelper
  # Builds a wa.me click-to-chat link with a pre-filled message.
  def whatsapp_link(phone, message)
    number = whatsapp_number(phone)
    return nil if number.blank?

    "https://wa.me/#{number}?text=#{ERB::Util.url_encode(message)}"
  end

  # Normalizes a free-text phone number into the digits-only, country-code-prefixed
  # format wa.me requires. Assumes India (+91) when no country code is present,
  # since phone numbers in this app are entered as plain 10-digit local numbers.
  def whatsapp_number(phone)
    digits = phone.to_s.gsub(/\D/, "")
    return nil if digits.blank?

    digits = digits.delete_prefix("0") if digits.size == 11 && digits.start_with?("0")
    digits = "91#{digits}" if digits.size == 10
    digits
  end

  # Builds a wa.me click-to-chat link that opens WhatsApp with a pre-filled
  # invite message for a guest speaker of a meeting/event, including venue.
  def whatsapp_speaker_invite_link(name, phone, subject, when_time, venue, forum)
    return nil if name.blank?

    whatsapp_link(phone, whatsapp_speaker_invite_message(name, subject, when_time, venue, forum))
  end

  def whatsapp_speaker_invite_message(name, subject, when_time, venue, forum)
    when_text = when_time.strftime("%A, %d %b %Y at %I:%M %p")
    venue_text = venue.present? ? "\n📍 Venue: #{venue}" : ""

    WhatsappTemplate.render(forum, :speaker_invite,
      name: name, subject: subject, forum_name: forum.name,
      when_text: when_text, venue_text: venue_text)
  end
end
