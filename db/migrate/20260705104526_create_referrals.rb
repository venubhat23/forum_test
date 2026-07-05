class CreateReferrals < ActiveRecord::Migration[8.0]
  def change
    create_table :referrals do |t|
      t.references :giver, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.integer :referral_type, null: false
      t.string :prospect_name, null: false
      t.string :prospect_phone
      t.text :notes

      t.timestamps
    end
  end
end
