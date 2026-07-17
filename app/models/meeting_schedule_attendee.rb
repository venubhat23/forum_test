class MeetingScheduleAttendee < ApplicationRecord
  belongs_to :meeting_schedule
  belongs_to :user
end
