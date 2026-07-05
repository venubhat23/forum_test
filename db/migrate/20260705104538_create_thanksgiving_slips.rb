class CreateThanksgivingSlips < ActiveRecord::Migration[8.0]
  def change
    create_table :thanksgiving_slips do |t|
      t.references :referral, null: false, foreign_key: true
      t.references :given_by, null: false, foreign_key: { to_table: :users }
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :notes

      t.timestamps
    end
  end
end
