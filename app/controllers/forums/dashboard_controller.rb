module Forums
  class DashboardController < BaseController
    def show
      load_lead_stats

      if @lead_stats_scope == :forum
        @chapters_count = @current_forum.chapters.count
        @members_count = @current_forum.users.member.count
        @guests_count = @current_forum.users.guest.count
        @renewing_this_month = @current_forum.users.member.where(renews_on: Date.current.beginning_of_month..Date.current.end_of_month).count
        @recent_chapters = @current_forum.chapters.order(created_at: :desc).limit(5)
      else
        load_personal_stats
      end

      load_attendance_stats
    end

    private

    def load_personal_stats
      this_month = Date.current.beginning_of_month..Date.current.end_of_month
      @referrals_given_count = current_user.referrals_given.count
      @attendance_this_month_count = current_user.attendances.where(occurred_on: this_month, present: true).count
      @one_to_ones_count = current_user.one_to_one_meetings_as_requester.count + current_user.one_to_one_meetings_as_requested.count
      @events_registered_count = current_user.event_registrations.count
    end

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
        # Forum-wide, every slip's giver and receiver both belong to this
        # forum, so the two totals are always equal — shown separately for
        # symmetry with the personal view below, where they differ.
        @thanksgiving_slips_given_count = base.where.not(thanksgiving_given_at: nil).count
        @thanksgiving_slips_received_count = @thanksgiving_slips_given_count
      else
        @lead_stats_scope = :personal
        @leads_created_count = current_user.created_leads.count
        @leads_requested_count = current_user.lead_taggings.count
        @leads_converted_count = current_user.accepted_leads.where(stage: :converted).count
        # A member gives a slip on leads they accepted and converted, and
        # receives one on leads they created that someone else converted.
        @thanksgiving_slips_given_count = current_user.accepted_leads.where.not(thanksgiving_given_at: nil).count
        @thanksgiving_slips_received_count = current_user.created_leads.where.not(thanksgiving_given_at: nil).count
      end
    end
  end
end
