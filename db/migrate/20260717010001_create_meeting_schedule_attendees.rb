class CreateMeetingScheduleAttendees < ActiveRecord::Migration[8.0]
  def change
    create_table :meeting_schedule_attendees do |t|
      t.references :meeting_schedule, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :meeting_schedule_attendees, [ :meeting_schedule_id, :user_id ], unique: true, name: "index_schedule_attendees_on_schedule_and_user"
  end
end
