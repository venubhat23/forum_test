module SuperAdmin
  class AnalyticsController < BaseController
    def show
      stats = Rails.cache.fetch("super_admin_analytics_stats", expires_in: 15.minutes) do
        {
          forums_by_month: Forum.group_by_month(:created_at, last: 6).count,
          revenue_by_month: Payment.group_by_month(:paid_on, last: 6).sum(:amount),
          attendance_by_month: Attendance.group_by_month(:occurred_on, last: 6).count,
          referrals_by_month: Referral.group_by_month(:created_at, last: 6).count,
          plan_distribution: Forum.joins(:plan).group("plans.name").count
        }
      end

      @forums_by_month = stats[:forums_by_month]
      @revenue_by_month = stats[:revenue_by_month]
      @attendance_by_month = stats[:attendance_by_month]
      @referrals_by_month = stats[:referrals_by_month]
      @plan_distribution = stats[:plan_distribution]
    end
  end
end
