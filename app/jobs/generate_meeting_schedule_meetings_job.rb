class GenerateMeetingScheduleMeetingsJob < ApplicationJob
  def perform(meeting_schedule_id)
    schedule = MeetingSchedule.find_by(id: meeting_schedule_id)
    return unless schedule

    schedule.generate!
  end
end
