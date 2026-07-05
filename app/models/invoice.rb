class Invoice < ApplicationRecord
  enum :status, { draft: 0, pending: 1, paid: 2, overdue: 3, cancelled: 4 }, default: :pending

  belongs_to :forum
  belongs_to :plan, optional: true
  belongs_to :coupon, optional: true
  has_many :payments, dependent: :destroy

  validates :amount, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :invoice_number, uniqueness: true

  before_validation :assign_invoice_number, on: :create

  def amount_paid
    payments.sum(:amount)
  end

  def balance_due
    amount - amount_paid
  end

  def mark_paid!(payment_method:, recorded_by:, reference_number: nil)
    transaction do
      payments.create!(
        amount: balance_due.positive? ? balance_due : amount,
        payment_method: payment_method,
        paid_on: Date.current,
        reference_number: reference_number,
        recorded_by: recorded_by
      )
      update!(status: :paid, paid_on: Date.current)
    end
  end

  private

  def assign_invoice_number
    return if invoice_number.present?

    loop do
      candidate = "INV-#{SecureRandom.hex(4).upcase}"
      unless Invoice.exists?(invoice_number: candidate)
        self.invoice_number = candidate
        break
      end
    end
  end
end
