module Forums
  class MyAttendanceController < BaseController
    def show
      @todays_meeting = current_user.chapter && current_user.chapter.meetings.find_by(scheduled_at: Date.current.all_day)
      @todays_meeting_attendance = @todays_meeting && Attendance.find_by(meeting_id: @todays_meeting.id, user_id: current_user.id)

      @todays_registrations = current_user.event_registrations
        .joins(:event)
        .where(events: { starts_at: Date.current.all_day })
        .includes(:event)

      @recent_attendances = current_user.attendances.order(occurred_on: :desc).limit(10)
    end
  end
end
