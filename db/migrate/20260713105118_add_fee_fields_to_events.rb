class AddFeeFieldsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :fee_amount, :decimal, precision: 10, scale: 2
    add_column :events, :payment_upi_id, :string
    add_column :events, :payment_bank_details, :text
  end
end
