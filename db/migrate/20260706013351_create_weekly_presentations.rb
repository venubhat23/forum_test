class CreateWeeklyPresentations < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_presentations do |t|
      t.references :chapter, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: { to_table: :users }
      t.references :meeting, foreign_key: true
      t.string :topic, null: false
      t.date :scheduled_on, null: false
      t.text :feedback

      t.timestamps
    end
  end
end
