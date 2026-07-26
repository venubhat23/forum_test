class AddBroadcastSupportToOfficeDarshans < ActiveRecord::Migration[8.0]
  def change
    add_column :office_darshans, :scope, :integer, default: 0, null: false
    add_reference :office_darshans, :chapter, foreign_key: true
    add_column :office_darshans, :venue, :string

    change_column_null :office_darshans, :visitor_id, true
  end
end
