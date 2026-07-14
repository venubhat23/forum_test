class AwardBadgesJob < ApplicationJob
  def perform(month = Date.current.prev_month.beginning_of_month)
    Chapter.find_each do |chapter|
      members = chapter.members.to_a
      next if members.empty?

      stats = ScorecardStats.new(members: members, month: month).call
      award_top_referrer(members, stats, month)
      award_perfect_attendance(members, stats, month)
      award_hundred_k_club(members, stats, month)
    end
  end

  private

  def award(user, key, month)
    badge = Badge.find_or_create_by!(user: user, key: key, period: month)
    user.notifications.create!(body: "🏆 You earned the #{badge.title} badge for #{month.strftime('%B %Y')}!") if badge.previously_new_record?
  end

  def award_top_referrer(members, stats, month)
    top = members.max_by { |m| stats[m.id][:referrals_given] }
    award(top, "top_referrer", month) if top && stats[top.id][:referrals_given].positive?
  end

  def award_perfect_attendance(members, stats, month)
    members.each { |m| award(m, "perfect_attendance", month) if stats[m.id][:attendance_pct] == 100.0 }
  end

  def award_hundred_k_club(members, stats, month)
    members.each { |m| award(m, "hundred_k_club", month) if stats[m.id][:business_generated] >= 100_000 }
  end
end
