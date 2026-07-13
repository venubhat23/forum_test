module CalendarHelper
  # Normalizes a calendar item (meeting/event/renewal) into display data
  # shared by the month-grid chips and the day-detail modal.
  def calendar_item_details(item)
    record = item[:record]

    case item[:type]
    when :meeting
      {
        css_class: "meeting",
        icon: "bi-people-fill",
        title: record.meeting_type.titleize,
        time: record.scheduled_at.strftime("%I:%M %p"),
        meta: record.chapter.name,
        path: forum_chapter_meeting_path(forum_slug: @current_forum.slug, chapter_id: record.chapter_id, id: record.id)
      }
    when :event
      {
        css_class: "event",
        icon: "bi-calendar-event-fill",
        title: record.title,
        time: record.starts_at.strftime("%I:%M %p"),
        meta: record.venue.presence,
        path: forum_event_path(forum_slug: @current_forum.slug, id: record.id)
      }
    when :renewal
      {
        css_class: "renewal",
        icon: "bi-arrow-repeat",
        title: record.display_name,
        time: nil,
        meta: "Membership renewal",
        path: forum_chapter_member_path(forum_slug: @current_forum.slug, chapter_id: record.chapter_id, id: record.id)
      }
    end
  end
end
