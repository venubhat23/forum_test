module Forums
  class ScorecardController < BaseController
    def show
      @month = parse_month
      @scope = scope_label

      @members = scope_members
      @stats_by_member = ScorecardStats.new(members: @members, month: @month).call
      @sorted_members = @members.sort_by { |m| -@stats_by_member[m.id][:score] }
      @badges_by_member = badges_for_month(@members)

      build_trends(@members) unless @scope == :personal
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

    def build_trends(members)
      member_ids = members.map(&:id)
      @referral_trend = Referral.where(referrer_id: member_ids).group_by_month(:created_at, last: 6).count
      @attendance_trend = Attendance.where(user_id: member_ids, event_type: :meeting).group_by_month(:occurred_on, last: 6).count
      @conversion_rate_trend = conversion_rate_trend
    end

    def conversion_rate_trend
      pool = @scope == :chapter ? current_user.chapter.users : @current_forum.users
      visitors = pool.where("role = ? OR converted_at IS NOT NULL", User.roles[:guest])
      new_visitors_by_month = visitors.group_by_month(:created_at, last: 6).count
      converted_by_month = pool.where.not(converted_at: nil).group_by_month(:converted_at, last: 6).count

      new_visitors_by_month.each_with_object({}) do |(month, total), hash|
        hash[month] = total.positive? ? ((converted_by_month[month].to_i / total.to_f) * 100).round(1) : 0
      end
    end

    def badges_for_month(members)
      Badge.where(user_id: members.map(&:id), period: @month.beginning_of_month).group_by(&:user_id)
    end
  end
end
