module Forums
  class CalendarController < BaseController
    def show
      @month = parse_month
      range = @month.beginning_of_month..@month.end_of_month

      @meetings = Meeting.joins(:chapter).includes(:chapter).where(chapters: { forum_id: @current_forum.id }).where(scheduled_at: range).order(:scheduled_at)
      @events = @current_forum.events.where(starts_at: range).order(:starts_at)
      @renewals = @current_forum.users.where(renews_on: range).order(:renews_on)

      @items_by_date = build_items_by_date
      @calendar_weeks = build_calendar_weeks
    end

    private

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
      items
    end

    def build_calendar_weeks
      start_date = @month.beginning_of_month.beginning_of_week(:sunday)
      end_date = @month.end_of_month.end_of_week(:sunday)
      (start_date..end_date).to_a.each_slice(7).to_a
    end
  end
end
