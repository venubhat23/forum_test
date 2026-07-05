class Payment < ApplicationRecord
  enum :payment_method, { cash: 0, bank_transfer: 1, upi: 2, cheque: 3, other: 4 }

  belongs_to :invoice
  belongs_to :recorded_by, class_name: "User"

  validates :amount, numericality: { greater_than: 0 }
  validates :paid_on, presence: true
end
