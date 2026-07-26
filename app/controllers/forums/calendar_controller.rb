module Forums
  class CalendarController < BaseController
    def show
      @month = parse_month
      range = @month.beginning_of_month..@month.end_of_month

      @meetings = Meeting.joins(:chapter).includes(:chapter).where(chapters: { forum_id: @current_forum.id }).where(scheduled_at: range).order(:scheduled_at)
      @events = @current_forum.events.where(starts_at: range).order(:starts_at)
      @renewals = @current_forum.users.where(renews_on: range).order(:renews_on)
      @one_to_one_meetings = my_one_to_one_meetings(range)
      @office_darshans = my_office_darshans(range)

      @items_by_date = build_items_by_date
      @calendar_weeks = build_calendar_weeks
    end

    private

    # The organizer sees their one-to-one meeting on the calendar as soon as
    # it's scheduled; the other person only sees it once they've accepted.
    def my_one_to_one_meetings(range)
      hosting = current_user.one_to_one_meetings_as_requester.where(forum_id: @current_forum.id, scheduled_at: range)
      attending = current_user.one_to_one_meetings_as_requested.where(forum_id: @current_forum.id, scheduled_at: range, status: [ :accepted, :completed ])
      (hosting.to_a + attending.to_a).uniq.sort_by(&:scheduled_at)
    end

    # Same rule for office darshans: the host always sees it; a single invited
    # visitor sees it once accepted, a broadcast (chapter/forum-wide) invitee
    # sees it once they RSVP as coming.
    def my_office_darshans(range)
      hosting = current_user.office_darshans_as_host.where(forum_id: @current_forum.id, scheduled_at: range)
      invited_direct = current_user.office_darshans_as_visitor.where(forum_id: @current_forum.id, scheduled_at: range, status: [ :accepted, :completed ])
      invited_broadcast = OfficeDarshan.where(forum_id: @current_forum.id, scheduled_at: range)
        .joins(:attendances).where(office_darshan_attendances: { user_id: current_user.id, rsvp_status: :coming })
      (hosting.to_a + invited_direct.to_a + invited_broadcast.to_a).uniq.sort_by(&:scheduled_at)
    end

    def parse_month
      Date.new(params[:year].to_i, params[:month].to_i, 1)
    rescue ArgumentError, TypeError
      Date.current.beginning_of_month
    end

    def build_items_by_date
      items = Hash.new { |h, k| h[k] = [] }
      @meetings.each { |m| items[m.scheduled_at.to_date] << { type: :meeting, record: m } }
      @events.each { |e| items[e.starts_at.to_date] << { type: :event, record: e } }
      @renewals.each { |u| items[u.renews_on] << { type: :renewal, record: u } }
      @one_to_one_meetings.each { |m| items[m.scheduled_at.to_date] << { type: :one_to_one, record: m } }
      @office_darshans.each { |d| items[d.scheduled_at.to_date] << { type: :darshan, record: d } }
      items
    end

    def build_calendar_weeks
      start_date = @month.beginning_of_month.beginning_of_week(:sunday)
      end_date = @month.end_of_month.end_of_week(:sunday)
      (start_date..end_date).to_a.each_slice(7).to_a
    end
  end
end
