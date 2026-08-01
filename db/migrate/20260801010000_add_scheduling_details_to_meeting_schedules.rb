class AddSchedulingDetailsToMeetingSchedules < ActiveRecord::Migration[8.0]
  def change
    add_column :meeting_schedules, :topic, :string
    add_column :meeting_schedules, :speaker, :string
    add_column :meeting_schedules, :speaker_phone, :string
    add_column :meeting_schedules, :meetings_generated_at, :datetime
  end
end
