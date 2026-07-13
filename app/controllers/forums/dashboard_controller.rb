module Forums
  class DashboardController < BaseController
    def show
      @chapters_count = @current_forum.chapters.count
      @members_count = @current_forum.users.member.count
      @guests_count = @current_forum.users.guest.count
      @renewing_this_month = @current_forum.users.member.where(renews_on: Date.current.beginning_of_month..Date.current.end_of_month).count
      @recent_chapters = @current_forum.chapters.order(created_at: :desc).limit(5)
      load_lead_stats
      load_attendance_stats
    end

    private

    def load_attendance_stats
      return unless can?(:manage, Attendance)

      this_month = Date.current.beginning_of_month..Date.current.end_of_month
      base = Attendance.joins(:user).where(users: { forum_id: @current_forum.id }).where(occurred_on: this_month)
      @attendance_present_this_month = base.where(present: true).count
      @attendance_absent_this_month = base.where(present: false).count

      forum_events = @current_forum.events.where(starts_at: this_month)
      event_registrations = EventRegistration.where(event_id: forum_events.select(:id))
      @event_attendance_present_this_month = event_registrations.where(attended: true).count
      @event_attendance_total_this_month = event_registrations.count
    end

    def load_lead_stats
      if can?(:manage, Lead)
        @lead_stats_scope = :forum
        base = @current_forum.leads
        @leads_created_count = base.count
        @leads_requested_count = base.where(stage: :requested).count
        @leads_converted_count = base.where(stage: :converted).count
        @thanksgiving_slips_count = base.where.not(thanksgiving_given_at: nil).count
      else
        @lead_stats_scope = :personal
        @leads_created_count = current_user.created_leads.count
        @leads_requested_count = current_user.lead_taggings.count
        @leads_converted_count = current_user.accepted_leads.where(stage: :converted).count
        @thanksgiving_slips_count = current_user.accepted_leads.where.not(thanksgiving_given_at: nil).count
      end
    end
  end
end
