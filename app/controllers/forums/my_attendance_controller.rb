module Forums
  class MyAttendanceController < BaseController
    def show
      @upcoming_meetings = current_user.chapter ?
        current_user.chapter.meetings.where(scheduled_at: Date.current.beginning_of_day..2.months.from_now).order(:scheduled_at) :
        Meeting.none
      @meeting_attendances = Attendance.where(meeting_id: @upcoming_meetings.map(&:id), user_id: current_user.id).index_by(&:meeting_id)

      @upcoming_registrations = current_user.event_registrations
        .joins(:event)
        .where("events.starts_at >= ?", Date.current.beginning_of_day)
        .includes(:event)
        .order("events.starts_at")
        .limit(5)

      @upcoming_one_to_ones = OneToOneMeeting.where(forum_id: @current_forum.id)
        .where("requester_id = :id OR requested_with_id = :id", id: current_user.id)
        .where(status: [ :requested, :accepted ])
        .includes(:requester, :requested_with)
        .order(:scheduled_at)
        .limit(5)

      @upcoming_darshan_attendances = current_user.office_darshan_attendances
        .joins(:office_darshan)
        .where("office_darshans.scheduled_at >= ?", Date.current.beginning_of_day)
        .includes(office_darshan: :host)
        .order("office_darshans.scheduled_at")
        .limit(5)

      @hosted_darshans = current_user.office_darshans_as_host
        .where("scheduled_at >= ?", Date.current.beginning_of_day)
        .where.not(status: [ :completed, :cancelled ])
        .order(:scheduled_at)
        .limit(5)

      @recent_attendances = current_user.attendances.order(occurred_on: :desc).limit(10)
    end
  end
end
