class AddInvoiceFieldsToFeePayments < ActiveRecord::Migration[8.0]
  def up
    add_column :fee_payments, :invoice_number, :string
    add_column :fee_payments, :payment_method, :integer

    execute <<~SQL
      UPDATE fee_payments SET invoice_number = 'INV-' || UPPER(SUBSTRING(MD5(id::text || random()::text), 1, 8))
      WHERE invoice_number IS NULL
    SQL

    change_column_null :fee_payments, :invoice_number, false
    add_index :fee_payments, :invoice_number, unique: true
  end

  def down
    remove_index :fee_payments, :invoice_number
    remove_column :fee_payments, :invoice_number
    remove_column :fee_payments, :payment_method
  end
end
