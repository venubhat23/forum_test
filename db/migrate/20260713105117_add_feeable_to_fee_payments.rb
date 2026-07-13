class AddFeeableToFeePayments < ActiveRecord::Migration[8.0]
  def change
    add_reference :fee_payments, :feeable, polymorphic: true, null: true
  end
end
