module Forums
  class AnalyticsController < BaseController
    before_action { authorize! :access, :forum_reports }

    def show
      user_ids = @current_forum.users.pluck(:id)

      @membership_growth = @current_forum.users.member.group_by_month(:created_at, last: 6).count
      @attendance_trend = Attendance.where(user_id: user_ids).group_by_month(:occurred_on, last: 6).count
      @referral_trend = Referral.joins("INNER JOIN users givers ON givers.id = referrals.giver_id")
        .where(givers: { forum_id: @current_forum.id }).group_by_month(:created_at, last: 6).count
      @revenue_trend = FeePayment.where(user_id: user_ids, status: :paid).group_by_month(:paid_on, last: 6).sum(:amount)
      @business_generated_trend = ThanksgivingSlip.joins("INNER JOIN referrals ON referrals.id = thanksgiving_slips.referral_id")
        .joins("INNER JOIN users givers ON givers.id = referrals.giver_id")
        .where(givers: { forum_id: @current_forum.id }).group_by_month("thanksgiving_slips.created_at", last: 6).sum(:amount)
      @event_participation = Event.where(forum_id: @current_forum.id).joins(:event_registrations).group(:title).count
      @chapter_performance = @current_forum.chapters.left_joins(:users).group(:name).count
      @guest_conversion = { "Converted" => @current_forum.users.where.not(converted_at: nil).count, "Still Guests" => @current_forum.users.guest.count }
    end
  end
end
