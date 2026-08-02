class AddPaymentFieldsToMeetingSchedules < ActiveRecord::Migration[8.0]
  def change
    add_column :meeting_schedules, :payment_upi_id, :string
    add_column :meeting_schedules, :payment_bank_details, :text
  end
end
