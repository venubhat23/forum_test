class OfficeDarshanReminderJob < ApplicationJob
  def perform
    OfficeDarshan.scheduled.where(scheduled_at: Time.current..2.days.from_now).find_each do |darshan|
      next if darshan.attendances.where(reminded_at: 12.hours.ago..).exists?

      remind_host(darshan)
      remind_attendees(darshan)
    end
  end

  private

  def remind_host(darshan)
    darshan.host.notifications.create!(
      body: "Reminder: your office darshan visit is on #{darshan.scheduled_at.strftime('%d %b, %I:%M %p')} — " \
            "#{darshan.coming_count} coming, #{darshan.pending_count} yet to respond."
    )
  end

  def remind_attendees(darshan)
    darshan.attendances.where(rsvp_status: [ :invited, :coming ]).find_each do |attendance|
      body = if attendance.coming?
        "Reminder: office darshan visit on #{darshan.scheduled_at.strftime('%d %b, %I:%M %p')}#{" at #{darshan.venue}" if darshan.venue.present?}."
      else
        "You haven't responded yet to the office darshan invite for #{darshan.scheduled_at.strftime('%d %b')}."
      end
      attendance.user.notifications.create!(body: body)
      attendance.update_column(:reminded_at, Time.current)
    end
  end
end
