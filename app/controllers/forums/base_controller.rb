module Forums
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_current_forum
    before_action :authorize_forum_access!
    before_action :set_active_announcements
    before_action :set_pending_fee_reminders

    private

    def set_active_announcements
      seen_ids = session[:seen_announcement_ids] ||= []
      @active_announcements = Announcement.for_forum(@current_forum).reject { |a| seen_ids.include?(a.id) }
      session[:seen_announcement_ids] = seen_ids + @active_announcements.map(&:id)
    end

    def set_pending_fee_reminders
      seen_ids = session[:seen_fee_reminder_ids] ||= []

      events = @current_forum.events.includes(:fee_payments).where("starts_at >= ?", Time.current).where.not(fee_amount: nil)
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
        meetings = Meeting.includes(:fee_payments).where(chapter_id: current_user.chapter_id).where("scheduled_at >= ?", Time.current).where.not(fee_amount: nil)
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
