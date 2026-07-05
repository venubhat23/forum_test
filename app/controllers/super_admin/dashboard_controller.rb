module SuperAdmin
  class DashboardController < BaseController
    def show
      @total_forums = Forum.count
      @active_forums = Forum.active.count
      @trial_forums = Forum.trial.count
      @suspended_forums = Forum.suspended.count
      @total_chapters = Chapter.count
      @total_forum_admins = User.forum_admin.count
      @recent_forums = Forum.order(created_at: :desc).limit(5)

      @revenue_collected = Payment.sum(:amount)
      @business_generated = ThanksgivingSlip.sum(:amount)
      @total_referrals = Referral.count
      @upcoming_renewals = Forum.where(renews_on: Date.current..30.days.from_now.to_date).count
      @overdue_invoices = Invoice.where(status: :overdue).or(Invoice.where("due_date < ? AND status = ?", Date.current, Invoice.statuses[:pending])).count
      @todays_attendance = Attendance.where(occurred_on: Date.current).count
      @pending_forum_requests = ForumRequest.pending.count
      @open_support_tickets = SupportTicket.where(status: [ :open, :in_progress ]).count
    end
  end
end
