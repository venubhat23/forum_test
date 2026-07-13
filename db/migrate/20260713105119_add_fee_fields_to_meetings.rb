class AddFeeFieldsToMeetings < ActiveRecord::Migration[8.0]
  def change
    add_column :meetings, :fee_amount, :decimal, precision: 10, scale: 2
    add_column :meetings, :payment_upi_id, :string
    add_column :meetings, :payment_bank_details, :text
  end
end
