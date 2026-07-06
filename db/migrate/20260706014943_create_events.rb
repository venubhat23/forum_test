class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :forum, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :event_type, null: false, default: 0
      t.datetime :starts_at, null: false
      t.string :venue
      t.datetime :registration_opens_at
      t.datetime :registration_closes_at

      t.timestamps
    end
  end
end
