class Invoice < ApplicationRecord
  enum :status, { draft: 0, pending: 1, paid: 2, overdue: 3, cancelled: 4, partially_paid: 5 }, default: :pending

  has_secure_token :share_token

  belongs_to :forum
  belongs_to :plan, optional: true
  belongs_to :coupon, optional: true
  belongs_to :user, optional: true
  has_many :payments, dependent: :destroy

  validates :amount, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :invoice_number, uniqueness: true

  before_validation :assign_invoice_number, on: :create

  # True for invoices a forum/chapter admin raises against one of their
  # members, as opposed to the platform-level invoices super admins raise
  # against a forum for its subscription.
  def member_invoice?
    user_id.present?
  end

  def billed_to_name
    user&.display_name || forum.name
  end

  def amount_paid
    payments.sum(:amount)
  end

  # Editing or deleting an invoice after money has been recorded against it
  # would silently corrupt payment history, so both actions are blocked once
  # any payment exists.
  def locked_for_edits?
    payments.exists?
  end

  def balance_due
    amount - amount_paid
  end

  # Records money received against this invoice. If it covers the remaining
  # balance the invoice becomes fully paid, otherwise it's left partially paid.
  # Locks the row so concurrent partial payments can't race past each other.
  def record_payment!(received_amount:, payment_method:, recorded_by:, reference_number: nil)
    transaction do
      lock!
      amount_to_record = [ received_amount.to_d, balance_due ].min
      raise ArgumentError, "amount must be positive" unless amount_to_record.positive?

      payments.create!(
        amount: amount_to_record,
        payment_method: payment_method,
        paid_on: Date.current,
        reference_number: reference_number,
        recorded_by: recorded_by
      )

      fully_paid = amount_paid >= amount
      update!(status: fully_paid ? :paid : :partially_paid, paid_on: fully_paid ? Date.current : paid_on)
    end
  end

  def mark_paid!(payment_method:, recorded_by:, reference_number: nil)
    record_payment!(
      received_amount: balance_due.positive? ? balance_due : amount,
      payment_method: payment_method,
      recorded_by: recorded_by,
      reference_number: reference_number
    )
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
