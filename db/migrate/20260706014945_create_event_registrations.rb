class CreateEventRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :event_registrations do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :attended, null: false, default: false

      t.timestamps
    end
    add_index :event_registrations, [ :event_id, :user_id ], unique: true
  end
end
