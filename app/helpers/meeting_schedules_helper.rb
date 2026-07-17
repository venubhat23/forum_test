module MeetingSchedulesHelper
  # Builds a wa.me click-to-chat link that opens WhatsApp with a pre-filled
  # invite message for the given attendee and recurring meeting schedule.
  def whatsapp_schedule_invite_link(user, schedule, forum)
    whatsapp_link(user.phone, whatsapp_schedule_invite_message(user, schedule, forum))
  end

  def whatsapp_schedule_invite_message(user, schedule, forum)
    when_text = "Every #{schedule.day_name}, #{schedule.start_time.strftime('%I:%M %p')}–#{schedule.end_time.strftime('%I:%M %p')}"
    range_text = "#{schedule.start_date.strftime('%d %b %Y')} to #{schedule.end_date.strftime('%d %b %Y')}"
    venue_text = schedule.venue.present? ? "\n📍 Venue: #{schedule.venue}" : ""
    agenda_text = schedule.agenda.present? ? "\n📋 Agenda: #{schedule.agenda}" : ""

    <<~MSG.strip
      Hi #{user.display_name}! 👋

      You're invited to join *#{schedule.title.presence || "#{schedule.day_name} Meetings"}* at #{forum.name}! 🎉

      🗓️ #{when_text}
      📅 #{range_text}#{venue_text}#{agenda_text}

      Mark your calendar — we'd love to see you there every time! 😊
    MSG
  end
end
