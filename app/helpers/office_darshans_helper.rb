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
    "Hi #{darshan.visitor.display_name}! 🙏\n\nThank you so much for visiting our office on #{darshan.scheduled_at.strftime('%d %b %Y')}. It was wonderful hosting you — looking forward to more collaboration! 🤝"
  end

  def whatsapp_darshan_visitor_thankyou_message(darshan)
    "Hi #{darshan.host.display_name}! 🙏\n\nThank you for hosting me at your office on #{darshan.scheduled_at.strftime('%d %b %Y')}. Really enjoyed the visit and looking forward to working together! 🤝"
  end
end
