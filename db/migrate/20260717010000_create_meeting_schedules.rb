class CreateMeetingSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :meeting_schedules do |t|
      t.references :chapter, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.string :title
      t.integer :day_of_week, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :venue
      t.text :agenda
      t.text :notes

      t.timestamps
    end
  end
end
