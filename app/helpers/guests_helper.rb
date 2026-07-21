module GuestsHelper
  # Builds a wa.me click-to-chat link that opens WhatsApp with a pre-filled
  # invite message for the given guest and event.
  def whatsapp_invite_link(guest, event, forum)
    whatsapp_link(guest.phone, whatsapp_invite_message(guest, event, forum))
  end

  def whatsapp_invite_message(guest, event, forum)
    when_text = event.starts_at.strftime("%A, %d %b %Y at %I:%M %p")
    venue_text = event.venue.present? ? "\n📍 Venue: #{event.venue}" : ""

    WhatsappTemplate.render(forum, :event_invite,
      full_name: guest.full_name, event_title: event.title, forum_name: forum.name,
      when_text: when_text, venue_text: venue_text)
  end
end
