class CreateForums < ActiveRecord::Migration[8.0]
  def change
    create_table :forums do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :status, null: false, default: 1

      t.timestamps
    end
    add_index :forums, :slug, unique: true
  end
end
