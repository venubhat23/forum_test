module OneToOneMeetingsHelper
  include WhatsappHelper

  def whatsapp_one_to_one_thankyou_link(meeting, sender)
    if sender.id == meeting.requester_id
      whatsapp_link(meeting.requested_with.phone, whatsapp_one_to_one_requester_thankyou_message(meeting))
    elsif sender.id == meeting.requested_with_id
      whatsapp_link(meeting.requester.phone, whatsapp_one_to_one_requested_with_thankyou_message(meeting))
    end
  end

  def whatsapp_one_to_one_requester_thankyou_message(meeting)
    WhatsappTemplate.render(meeting.forum, :one_to_one_thankyou_requester,
      requested_with_name: meeting.requested_with.display_name, scheduled_at: meeting.scheduled_at.strftime("%d %b %Y"))
  end

  def whatsapp_one_to_one_requested_with_thankyou_message(meeting)
    WhatsappTemplate.render(meeting.forum, :one_to_one_thankyou_requested_with,
      requester_name: meeting.requester.display_name, scheduled_at: meeting.scheduled_at.strftime("%d %b %Y"))
  end
end
