class RestructureOfficeDarshansForHostVisitorFlow < ActiveRecord::Migration[8.0]
  def change
    remove_reference :office_darshans, :member, foreign_key: { to_table: :users }
    add_reference :office_darshans, :host, null: false, foreign_key: { to_table: :users }
    add_reference :office_darshans, :visitor, null: false, foreign_key: { to_table: :users }

    remove_column :office_darshans, :visit_date, :date
    add_column :office_darshans, :scheduled_at, :datetime, null: false

    add_column :office_darshans, :confirmed_at, :datetime
    add_column :office_darshans, :thanked_at, :datetime
  end
end
