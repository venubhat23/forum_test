class AddStatusToAttendances < ActiveRecord::Migration[8.0]
  def up
    add_column :attendances, :status, :integer, default: 0, null: false

    # Backfill: existing rows only ever recorded present/absent, so map them
    # straight to attended/absent rather than leaving them "not_marked".
    execute <<~SQL.squish
      UPDATE attendances SET status = CASE WHEN present THEN 2 ELSE 3 END
    SQL
  end

  def down
    remove_column :attendances, :status
  end
end
