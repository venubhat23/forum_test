module Forums
  class ScorecardController < BaseController
    def show
      @month = parse_month
      @scope = scope_label

      @members = scope_members
      @stats_by_member = build_stats(@members)
      @sorted_members = @members.sort_by { |m| -@stats_by_member[m.id][:business_generated] }
    end

    private

    def parse_month
      Date.new(params[:year].to_i, params[:month].to_i, 1)
    rescue ArgumentError, TypeError
      Date.current.beginning_of_month
    end

    def scope_label
      if current_user.forum_admin?
        :forum
      elsif current_user.chapter_admin?
        :chapter
      else
        :personal
      end
    end

    def scope_members
      case @scope
      when :forum
        @current_forum.users.member.order(:full_name)
      when :chapter
        current_user.chapter.members.order(:full_name)
      else
        [ current_user ]
      end
    end

    def build_stats(members)
      member_ids = members.map(&:id)
      date_range = @month.beginning_of_month..@month.end_of_month
      time_range = date_range.first.beginning_of_day..date_range.last.end_of_day

      referrals_given = Referral.where(referrer_id: member_ids, created_at: time_range).group(:referrer_id).count
      referrals_received = Referral.where(referred_user_id: member_ids, created_at: time_range).group(:referred_user_id).count
      leads_created = Lead.where(created_by_id: member_ids, created_at: time_range).group(:created_by_id).count
      leads_converted = Lead.where(accepted_by_id: member_ids, stage: :converted, thanksgiving_given_at: time_range).group(:accepted_by_id).count

      one_to_ones_as_requester = OneToOneMeeting.where(status: :completed, requester_id: member_ids, scheduled_at: time_range).group(:requester_id).count
      one_to_ones_as_requested = OneToOneMeeting.where(status: :completed, requested_with_id: member_ids, scheduled_at: time_range).group(:requested_with_id).count

      chapter_ids = members.map(&:chapter_id).compact.uniq
      total_meetings_by_chapter = Meeting.where(chapter_id: chapter_ids, scheduled_at: time_range).group(:chapter_id).count
      attendance_present = Attendance.where(user_id: member_ids, event_type: :meeting, present: true, occurred_on: date_range).group(:user_id).count

      thanksgiving_business = ThanksgivingSlip.where(given_by_id: member_ids, created_at: time_range).group(:given_by_id).sum(:amount)
      lead_business = Lead.where(accepted_by_id: member_ids, stage: :converted, thanksgiving_given_at: time_range).group(:accepted_by_id).sum(:thanksgiving_amount)

      members.each_with_object({}) do |member, hash|
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
    end
  end
end
