class AddMeetingScheduleIdToMeetings < ActiveRecord::Migration[8.0]
  def change
    add_reference :meetings, :meeting_schedule, foreign_key: true
  end
end
