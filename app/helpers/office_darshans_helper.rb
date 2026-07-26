module OfficeDarshansHelper
  include WhatsappHelper

  RSVP_BADGE_CLASSES = { "invited" => "bg-warning-subtle text-warning-emphasis", "coming" => "bg-success-subtle text-success-emphasis", "not_coming" => "bg-secondary-subtle text-secondary-emphasis" }.freeze

  def rsvp_badge_class(rsvp_status)
    RSVP_BADGE_CLASSES.fetch(rsvp_status, "bg-secondary")
  end

  def whatsapp_darshan_reminder_link(darshan, attendee)
    message = "Reminder: office darshan visit hosted by #{darshan.host.display_name} on #{darshan.scheduled_at.strftime('%d %b %Y %H:%M')}#{" at #{darshan.venue}" if darshan.venue.present?}. Please confirm if you're coming!"
    whatsapp_link(attendee.phone, message)
  end

  def whatsapp_darshan_thankyou_link(darshan, sender)
    if sender.id == darshan.host_id
      whatsapp_link(darshan.visitor.phone, whatsapp_darshan_host_thankyou_message(darshan))
    elsif sender.id == darshan.visitor_id
      whatsapp_link(darshan.host.phone, whatsapp_darshan_visitor_thankyou_message(darshan))
    end
  end

  def whatsapp_darshan_host_thankyou_message(darshan)
    WhatsappTemplate.render(darshan.forum, :darshan_thankyou_host,
      visitor_name: darshan.visitor.display_name, scheduled_at: darshan.scheduled_at.strftime("%d %b %Y"))
  end

  def whatsapp_darshan_visitor_thankyou_message(darshan)
    WhatsappTemplate.render(darshan.forum, :darshan_thankyou_visitor,
      host_name: darshan.host.display_name, scheduled_at: darshan.scheduled_at.strftime("%d %b %Y"))
  end
end
