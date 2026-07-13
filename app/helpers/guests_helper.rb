module GuestsHelper
  # Builds a wa.me click-to-chat link that opens WhatsApp with a pre-filled
  # invite message for the given guest and event.
  def whatsapp_invite_link(guest, event, forum)
    number = whatsapp_number(guest.phone)
    return nil if number.blank?

    "https://wa.me/#{number}?text=#{ERB::Util.url_encode(whatsapp_invite_message(guest, event, forum))}"
  end

  def whatsapp_invite_message(guest, event, forum)
    when_text = event.starts_at.strftime("%A, %d %b %Y at %I:%M %p")
    venue_text = event.venue.present? ? "\n📍 Venue: #{event.venue}" : ""

    <<~MSG.strip
      Hi #{guest.full_name}! 👋

      You're warmly invited to *#{event.title}*, hosted by #{forum.name}! 🎉

      🗓️ #{when_text}#{venue_text}

      We'd love to have you join us — come connect, network, and grow with us!

      See you there! 😊
    MSG
  end

  private

  # Normalizes a free-text phone number into the digits-only, country-code-prefixed
  # format wa.me requires. Assumes India (+91) when no country code is present,
  # since guest phone numbers are entered as plain 10-digit local numbers.
  def whatsapp_number(phone)
    digits = phone.to_s.gsub(/\D/, "")
    return nil if digits.blank?

    digits = digits.delete_prefix("0") if digits.size == 11 && digits.start_with?("0")
    digits = "91#{digits}" if digits.size == 10
    digits
  end
end
