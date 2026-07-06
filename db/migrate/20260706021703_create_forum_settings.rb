class CreateForumSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :forum_settings do |t|
      t.references :forum, null: false, foreign_key: true, index: { unique: true }
      t.string :theme_color, default: "#4f46e5"
      t.string :invoice_prefix, default: "INV"
      t.text :attendance_rules
      t.text :meeting_rules
      t.text :membership_rules

      t.timestamps
    end
  end
end
