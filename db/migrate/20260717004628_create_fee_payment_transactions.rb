class CreateFeePaymentTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :fee_payment_transactions do |t|
      t.references :fee_payment, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :payment_method
      t.date :paid_on, null: false

      t.timestamps
    end

    reversible do |dir|
      dir.up do
        # status = 1 is FeePayment's "paid" enum value; migrations must not
        # reference the live model, so it's inlined here deliberately.
        execute <<~SQL
          INSERT INTO fee_payment_transactions (fee_payment_id, amount, payment_method, paid_on, created_at, updated_at)
          SELECT id, amount, payment_method, COALESCE(paid_on, updated_at::date), created_at, updated_at
          FROM fee_payments
          WHERE status = 1
        SQL
      end
    end
  end
end
