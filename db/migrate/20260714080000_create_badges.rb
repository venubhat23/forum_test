class CreateBadges < ActiveRecord::Migration[8.0]
  def change
    create_table :badges do |t|
      t.references :user, null: false, foreign_key: true
      t.string :key, null: false
      t.date :period, null: false

      t.timestamps
    end
    add_index :badges, [ :user_id, :key, :period ], unique: true
  end
end
