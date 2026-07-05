module SuperAdmin
  class AnalyticsController < BaseController
    def show
      @forums_by_month = Forum.group_by_month(:created_at, last: 6).count
      @revenue_by_month = Payment.group_by_month(:paid_on, last: 6).sum(:amount)
      @attendance_by_month = Attendance.group_by_month(:occurred_on, last: 6).count
      @referrals_by_month = Referral.group_by_month(:created_at, last: 6).count
      @plan_distribution = Forum.joins(:plan).group("plans.name").count
    end
  end
end
