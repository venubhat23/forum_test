class FeePaymentTransaction < ApplicationRecord
  enum :payment_method, { cash: 0, bank_transfer: 1, upi: 2, cheque: 3, other: 4 }

  belongs_to :fee_payment

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :paid_on, presence: true
end
