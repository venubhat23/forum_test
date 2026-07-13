class AddEventIdToAttendances < ActiveRecord::Migration[8.0]
  def change
    add_reference :attendances, :event, foreign_key: true

    add_index :attendances, [ :user_id, :meeting_id ], unique: true
    add_index :attendances, [ :user_id, :event_id ], unique: true
  end
end
