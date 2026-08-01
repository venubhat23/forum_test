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

  # The URL for the guest's own public, no-login profile form. Generates
  # and persists a token on first use so guests added before this feature
  # existed still get a working link.
  def guest_profile_form_link(guest)
    guest.regenerate_profile_token if guest.profile_token.blank?
    guest_profile_form_url(token: guest.profile_token)
  end

  # Builds a wa.me click-to-chat link inviting the guest to fill in their
  # own profile (business details, KYC docs, etc.) via the public form —
  # whatever they submit shows up pre-filled on the admin's Convert page.
  def whatsapp_profile_form_link(guest, forum)
    whatsapp_link(guest.phone, whatsapp_profile_form_message(guest, forum))
  end

  def whatsapp_profile_form_message(guest, forum)
    WhatsappTemplate.render(forum, :guest_profile_form_invite,
      full_name: guest.full_name, forum_name: forum.name, form_url: guest_profile_form_link(guest))
  end
end
