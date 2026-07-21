module OfficeDarshansHelper
  include WhatsappHelper

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
