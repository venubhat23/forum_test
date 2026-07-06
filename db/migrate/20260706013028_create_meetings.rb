class CreateMeetings < ActiveRecord::Migration[8.0]
  def change
    create_table :meetings do |t|
      t.references :chapter, null: false, foreign_key: true
      t.integer :meeting_type, null: false, default: 0
      t.datetime :scheduled_at, null: false
      t.string :venue
      t.string :speaker
      t.text :agenda
      t.text :minutes

      t.timestamps
    end
  end
end
