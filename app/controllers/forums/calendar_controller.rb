module Forums
  class CalendarController < BaseController
    def show
      range = Date.current.beginning_of_month..Date.current.end_of_month
      @meetings = Meeting.joins(:chapter).where(chapters: { forum_id: @current_forum.id }).where(scheduled_at: range).order(:scheduled_at)
      @events = @current_forum.events.where(starts_at: range).order(:starts_at)
      @renewals = @current_forum.users.where(renews_on: range).order(:renews_on)
    end
  end
end
