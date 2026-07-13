module GuestsHelper
  # Builds a wa.me click-to-chat link that opens WhatsApp with a pre-filled
  # invite message for the given guest and event.
  def whatsapp_invite_link(guest, event, forum)
    whatsapp_link(guest.phone, whatsapp_invite_message(guest, event, forum))
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
end
