class ScorecardStats
  # Out of 100. Leads converted and business generated carry the most weight
  # since they reflect closed value, not just activity volume.
  COUNT_WEIGHTS = {
    referrals_given: 15,
    referrals_received: 10,
    leads_created: 10,
    leads_converted: 20,
    one_to_ones: 15,
    business_generated: 15
  }.freeze
  ATTENDANCE_WEIGHT = 15

  def initialize(members:, month:)
    @members = members
    @month = month
  end

  def call
    member_ids = @members.map(&:id)
    date_range = @month.beginning_of_month..@month.end_of_month
    time_range = date_range.first.beginning_of_day..date_range.last.end_of_day

    referrals_given = Referral.where(referrer_id: member_ids, created_at: time_range).group(:referrer_id).count
    referrals_received = Referral.where(referred_user_id: member_ids, created_at: time_range).group(:referred_user_id).count
    leads_created = Lead.where(created_by_id: member_ids, created_at: time_range).group(:created_by_id).count
    leads_converted = Lead.where(accepted_by_id: member_ids, stage: :converted, thanksgiving_given_at: time_range).group(:accepted_by_id).count

    one_to_ones_as_requester = OneToOneMeeting.where(status: :completed, requester_id: member_ids, scheduled_at: time_range).group(:requester_id).count
    one_to_ones_as_requested = OneToOneMeeting.where(status: :completed, requested_with_id: member_ids, scheduled_at: time_range).group(:requested_with_id).count

    chapter_ids = @members.map(&:chapter_id).compact.uniq
    total_meetings_by_chapter = Meeting.where(chapter_id: chapter_ids, scheduled_at: time_range).group(:chapter_id).count
    attendance_present = Attendance.where(user_id: member_ids, event_type: :meeting, present: true, occurred_on: date_range).group(:user_id).count

    thanksgiving_business = ThanksgivingSlip.where(given_by_id: member_ids, created_at: time_range).group(:given_by_id).sum(:amount)
    lead_business = Lead.where(accepted_by_id: member_ids, stage: :converted, thanksgiving_given_at: time_range).group(:accepted_by_id).sum(:thanksgiving_amount)

    stats = @members.each_with_object({}) do |member, hash|
      total_meetings = total_meetings_by_chapter[member.chapter_id].to_i
      present = attendance_present[member.id].to_i
      attendance_pct = total_meetings.positive? ? ((present.to_f / total_meetings) * 100).round(1) : 0

      hash[member.id] = {
        referrals_given: referrals_given[member.id].to_i,
        referrals_received: referrals_received[member.id].to_i,
        leads_created: leads_created[member.id].to_i,
        leads_converted: leads_converted[member.id].to_i,
        one_to_ones: one_to_ones_as_requester[member.id].to_i + one_to_ones_as_requested[member.id].to_i,
        attendance_pct: attendance_pct,
        business_generated: thanksgiving_business[member.id].to_i + lead_business[member.id].to_i
      }
    end

    apply_scores(stats)
  end

  private

  # Min-max normalizes each count-based metric against the best performer in
  # the group (so no member can be judged against an absolute target), then
  # combines the normalized metrics with COUNT_WEIGHTS. Attendance is already
  # a percentage, so it's weighted directly instead of being re-normalized.
  def apply_scores(stats)
    maxes = COUNT_WEIGHTS.keys.to_h { |key| [ key, stats.values.map { |s| s[key] }.max.to_f ] }

    stats.each_value do |member_stats|
      points = COUNT_WEIGHTS.sum do |key, weight|
        max = maxes[key]
        max.positive? ? (member_stats[key] / max) * weight : 0
      end
      points += (member_stats[:attendance_pct] / 100.0) * ATTENDANCE_WEIGHT

      member_stats[:score] = points.round(1)
    end

    stats
  end
end
