class CreateOneToOneMeetings < ActiveRecord::Migration[8.0]
  def change
    create_table :one_to_one_meetings do |t|
      t.references :forum, null: false, foreign_key: true
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :requested_with, null: false, foreign_key: { to_table: :users }
      t.datetime :scheduled_at, null: false
      t.integer :status, null: false, default: 0
      t.text :notes
      t.date :follow_up_on

      t.timestamps
    end
  end
end
