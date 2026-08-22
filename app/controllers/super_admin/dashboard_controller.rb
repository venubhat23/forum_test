module SuperAdmin
  class DashboardController < BaseController
    def show
      stats = Rails.cache.fetch("super_admin_dashboard_stats", expires_in: 2.minutes) do
        {
          total_forums: Forum.count,
          active_forums: Forum.active.count,
          trial_forums: Forum.trial.count,
          suspended_forums: Forum.suspended.count,
          total_chapters: Chapter.count,
          total_forum_admins: User.forum_admin.count,
          revenue_collected: Payment.sum(:amount),
          business_generated: ThanksgivingSlip.sum(:amount),
          total_referrals: Referral.count,
          upcoming_renewals: Forum.where(renews_on: Date.current..30.days.from_now.to_date).count,
          overdue_invoices: Invoice.where(status: :overdue).or(Invoice.where("due_date < ? AND status = ?", Date.current, Invoice.statuses[:pending])).count,
          todays_attendance: Attendance.where(occurred_on: Date.current).count,
          pending_forum_requests: ForumRequest.pending.count,
          open_support_tickets: SupportTicket.where(status: [ :open, :in_progress ]).count
        }
      end

      @total_forums = stats[:total_forums]
      @active_forums = stats[:active_forums]
      @trial_forums = stats[:trial_forums]
      @suspended_forums = stats[:suspended_forums]
      @total_chapters = stats[:total_chapters]
      @total_forum_admins = stats[:total_forum_admins]
      @recent_forums = Forum.order(created_at: :desc).limit(5)

      @revenue_collected = stats[:revenue_collected]
      @business_generated = stats[:business_generated]
      @total_referrals = stats[:total_referrals]
      @upcoming_renewals = stats[:upcoming_renewals]
      @overdue_invoices = stats[:overdue_invoices]
      @todays_attendance = stats[:todays_attendance]
      @pending_forum_requests = stats[:pending_forum_requests]
      @open_support_tickets = stats[:open_support_tickets]
    end
  end
end
