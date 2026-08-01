class AddMeetingFeePaidToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :meeting_fee_paid, :boolean, default: false, null: false
  end
end
