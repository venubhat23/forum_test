class CreateOfficeDarshanAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :office_darshan_attendances do |t|
      t.references :office_darshan, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rsvp_status, default: 0, null: false
      t.datetime :responded_at
      t.boolean :attended, default: false, null: false
      t.datetime :attended_at
      t.datetime :reminded_at
      t.integer :rating
      t.text :review_comment
      t.datetime :reviewed_at

      t.timestamps
    end

    add_index :office_darshan_attendances, [ :office_darshan_id, :user_id ], unique: true, name: "index_office_darshan_attendances_on_darshan_and_user"
  end
end
