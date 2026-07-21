require "csv"

module Forums
  class ReportsController < BaseController
    before_action :require_admin!

    def index
    end

    def members
      @members = @current_forum.users.member.includes(:chapter).order(:full_name)
      respond_with_csv(@members, "members", [ "Name", "Email", "Phone", "Chapter", "Status", "Renews On", "Member Since" ]) do |m|
        [ m.full_name, m.email, m.phone, m.chapter&.name, m.membership_status, m.renews_on, m.member_since ]
      end
    end

    def guests
      @guests = @current_forum.users.guest.includes(:chapter).order(:full_name)
      respond_with_csv(@guests, "guests", [ "Name", "Email", "Phone", "Chapter", "Nature of Business", "Joined" ]) do |g|
        [ g.full_name, g.email, g.phone, g.chapter&.name, g.nature_of_business, g.created_at ]
      end
    end

    def attendance
      @attendances = Attendance.joins(:user).includes(:user).where(users: { forum_id: @current_forum.id }).order(occurred_on: :desc)
      respond_with_csv(@attendances, "attendance", [ "User", "Event Type", "Date", "Present" ]) do |a|
        [ a.user.display_name, a.event_type, a.occurred_on, a.present ]
      end
    end

    def referrals
      @referrals = Referral.joins("INNER JOIN users givers ON givers.id = referrals.referrer_id")
        .includes(:giver, :receiver)
        .where(givers: { forum_id: @current_forum.id }).order(created_at: :desc)
      respond_with_csv(@referrals, "referrals", [ "Giver", "Receiver", "Prospect", "Type", "Status", "Date" ]) do |r|
        [ r.giver.display_name, r.receiver.display_name, r.prospect_name, r.referral_type, r.status, r.created_at ]
      end
    end

    def business_generated
      @slips = ThanksgivingSlip.joins("INNER JOIN referrals ON referrals.id = thanksgiving_slips.referral_id")
        .joins("INNER JOIN users givers ON givers.id = referrals.referrer_id")
        .includes(:given_by, referral: :giver)
        .where(givers: { forum_id: @current_forum.id }).order("thanksgiving_slips.created_at DESC")
      respond_with_csv(@slips, "business-generated", [ "Given By", "Referral Giver", "Amount", "Date" ]) do |s|
        [ s.given_by.display_name, s.referral.giver.display_name, s.amount, s.created_at ]
      end
    end

    def chapters
      @chapters = @current_forum.chapters.order(:name)
      role_counts = User.where(chapter_id: @chapters.map(&:id), role: %i[member guest committee_member])
        .group(:chapter_id, :role).count
      @chapter_role_counts = Hash.new(0).merge(role_counts)
      respond_with_csv(@chapters, "chapters", [ "Name", "Status", "Members", "Guests", "Committee", "Created" ]) do |c|
        [ c.name, c.status, @chapter_role_counts[[ c.id, "member" ]], @chapter_role_counts[[ c.id, "guest" ]], @chapter_role_counts[[ c.id, "committee_member" ]], c.created_at ]
      end
    end

    def meetings
      @meetings = Meeting.includes(:chapter).joins(:chapter).where(chapters: { forum_id: @current_forum.id }).order(scheduled_at: :desc)
      meetings = @meetings.to_a
      chapter_totals = User.where(chapter_id: meetings.map(&:chapter_id).uniq, role: :member).group(:chapter_id).count
      present_counts = Attendance.where(meeting_id: meetings.map(&:id), present: true).group(:meeting_id).count
      @meeting_attendance = meetings.each_with_object({}) do |m, hash|
        total = chapter_totals[m.chapter_id].to_i
        hash[m.id] = total.zero? ? 0 : ((present_counts[m.id].to_i.to_f / total) * 100).round(1)
      end
      respond_with_csv(@meetings, "meetings", [ "Chapter", "Type", "Date", "Attendance %" ]) do |m|
        [ m.chapter.name, m.meeting_type, m.scheduled_at, @meeting_attendance[m.id] ]
      end
    end

    def events
      @events = @current_forum.events.includes(:event_registrations).order(starts_at: :desc)
      respond_with_csv(@events, "events", [ "Title", "Type", "Date", "Registrants" ]) do |e|
        [ e.title, e.event_type, e.starts_at, e.event_registrations.size ]
      end
    end

    def renewals
      @renewals = @current_forum.users.member.where.not(renews_on: nil).order(:renews_on)
      respond_with_csv(@renewals, "renewals", [ "Name", "Email", "Renews On", "Status" ]) do |u|
        [ u.display_name, u.email, u.renews_on, u.membership_status ]
      end
    end

    private

    def require_admin!
      authorize! :access, :forum_reports
    end

    def respond_with_csv(records, filename, headers)
      respond_to do |format|
        format.html
        format.csv do
          data = CSV.generate(headers: true) do |csv|
            csv << headers
            records.each { |r| csv << yield(r) }
          end
          send_data data, filename: "#{filename}-#{@current_forum.slug}-#{Date.current}.csv"
        end
      end
    end
  end
end
