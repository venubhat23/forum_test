class AddFeeAmountToMeetingSchedules < ActiveRecord::Migration[8.0]
  def change
    add_column :meeting_schedules, :fee_amount, :decimal, precision: 10, scale: 2
  end
end
