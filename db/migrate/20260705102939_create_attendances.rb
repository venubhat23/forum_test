class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :event_type, null: false
      t.date :occurred_on, null: false
      t.boolean :present, null: false, default: true

      t.timestamps
    end
  end
end
