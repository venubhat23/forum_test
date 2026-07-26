module Forums
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_current_forum
    before_action :authorize_forum_access!
    before_action :set_active_announcements
    before_action :set_pending_fee_reminders
    before_action :set_pending_engagement_invites
    before_action :set_pending_event_rsvps

    private

    # Events the member is registered for but hasn't confirmed attendance on
    # yet. Once they answer (coming or not_coming), rsvp_status is no longer
    # "invited" so this stops appearing for good — no session dismissal needed.
    def set_pending_event_rsvps
      within_a_month = Time.current..1.month.from_now
      registrations = current_user.event_registrations.includes(:event)
        .where(rsvp_status: :invited).where(event: { starts_at: within_a_month })

      @pending_event_rsvps = registrations.map do |registration|
        event = registration.event
        {
          key: "event-rsvp-#{registration.id}",
          title: event.title,
          when_text: event.starts_at.strftime("%d %b %Y at %I:%M %p"),
          fee_amount: event.fee_amount,
          rsvp_path: rsvp_forum_event_registration_path(forum_slug: @current_forum.slug, event_id: event.id, id: registration.id)
        }
      end
    end

    def set_pending_engagement_invites
      seen_ids = session[:seen_engagement_invite_ids] ||= []
      within_a_month = Time.current..1.month.from_now
      items = []

      OneToOneMeeting.where(requested_with_id: current_user.id, status: :requested, scheduled_at: within_a_month).find_each do |meeting|
        items << {
          key: "o2o-#{meeting.id}",
          icon: "bi-person-lines-fill",
          title: "One-to-One Meeting Invite",
          subtitle: "#{meeting.requester.display_name} wants to meet you",
          when_text: meeting.scheduled_at.strftime("%d %b %Y at %I:%M %p"),
          path: forum_one_to_one_meeting_path(forum_slug: @current_forum.slug, id: meeting.id)
        }
      end

      OfficeDarshan.where(visitor_id: current_user.id, status: :invited, scheduled_at: within_a_month).find_each do |darshan|
        items << {
          key: "darshan-#{darshan.id}",
          icon: "bi-building",
          title: "Office Darshan Invite",
          subtitle: "#{darshan.host.display_name} invited you to visit",
          when_text: darshan.scheduled_at.strftime("%d %b %Y at %I:%M %p"),
          path: forum_office_darshan_path(forum_slug: @current_forum.slug, id: darshan.id)
        }
      end

      OfficeDarshanAttendance.includes(:office_darshan).where(user_id: current_user.id, rsvp_status: :invited)
        .where(office_darshan: { scheduled_at: within_a_month }).find_each do |attendance|
        darshan = attendance.office_darshan
        items << {
          key: "darshan-attendance-#{attendance.id}",
          icon: "bi-building",
          title: "Office Darshan Invite",
          subtitle: "#{darshan.host.display_name} invited you to visit",
          when_text: darshan.scheduled_at.strftime("%d %b %Y at %I:%M %p"),
          path: forum_office_darshan_path(forum_slug: @current_forum.slug, id: darshan.id)
        }
      end

      @pending_engagement_invites = items.reject { |i| seen_ids.include?(i[:key]) }
      session[:seen_engagement_invite_ids] = seen_ids + @pending_engagement_invites.map { |i| i[:key] }
    end

    def set_active_announcements
      seen_ids = session[:seen_announcement_ids] ||= []
      @active_announcements = Announcement.for_forum(@current_forum).reject { |a| seen_ids.include?(a.id) }
      session[:seen_announcement_ids] = seen_ids + @active_announcements.map(&:id)
    end

    def set_pending_fee_reminders
      seen_ids = session[:seen_fee_reminder_ids] ||= []
      this_month = Time.current..Date.current.end_of_month.end_of_day

      events = @current_forum.events.includes(:fee_payments).where(starts_at: this_month).where.not(fee_amount: nil)
      items = events.map do |event|
        fee = event.fee_payments.detect { |f| f.user_id == current_user.id }
        {
          key: "event-#{event.id}",
          title: event.title,
          when_text: event.starts_at.strftime("%d %b %Y at %I:%M %p"),
          fee_amount: event.fee_amount,
          paid: fee&.paid? || false,
          path: forum_event_path(forum_slug: @current_forum.slug, id: event.id)
        }
      end

      if current_user.chapter_id.present?
        meetings = Meeting.includes(:fee_payments).where(chapter_id: current_user.chapter_id).where(scheduled_at: this_month).where.not(fee_amount: nil)
        items += meetings.map do |meeting|
          fee = meeting.fee_payments.detect { |f| f.user_id == current_user.id }
          {
            key: "meeting-#{meeting.id}",
            title: "#{meeting.meeting_type.titleize} Meeting",
            when_text: meeting.scheduled_at.strftime("%d %b %Y at %I:%M %p"),
            fee_amount: meeting.fee_amount,
            paid: fee&.paid? || false,
            path: forum_chapter_meeting_path(forum_slug: @current_forum.slug, chapter_id: meeting.chapter_id, id: meeting.id)
          }
        end
      end

      @pending_fee_reminders = items.reject { |i| seen_ids.include?(i[:key]) }
      session[:seen_fee_reminder_ids] = seen_ids + @pending_fee_reminders.map { |i| i[:key] }
    end

    def set_current_forum
      @current_forum = Forum.find_by!(slug: params[:forum_slug])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Forum not found."
    end

    def authorize_forum_access!
      authorize! :access, @current_forum, message: "You don't have access to that forum."
    end
  end
end
