class CreateAnnouncements < ActiveRecord::Migration[8.0]
  def change
    create_table :announcements do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.integer :audience, null: false, default: 0
      t.references :forum, foreign_key: true
      t.references :plan, foreign_key: true
      t.datetime :published_at
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
