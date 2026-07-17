class FeePayment < ApplicationRecord
  enum :fee_type, { annual_membership: 0, meeting: 1, training: 2, event: 3 }
  enum :status, { pending: 0, paid: 1, partially_paid: 2 }, default: :pending
  enum :payment_method, { cash: 0, bank_transfer: 1, upi: 2, cheque: 3, other: 4 }

  ALLOWED_FEE_TYPES = {
    "member" => %w[annual_membership meeting training event],
    "guest" => %w[meeting event]
  }.freeze

  belongs_to :user
  belongs_to :feeable, polymorphic: true, optional: true
  has_many :fee_payment_transactions, dependent: :destroy

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :fee_type, presence: true
  validates :invoice_number, uniqueness: true
  validate :fee_type_allowed_for_role

  before_validation :assign_invoice_number, on: :create
  after_save :extend_membership_renewal, if: -> { annual_membership? && paid? && saved_change_to_status? }

  def paid_amount
    fee_payment_transactions.sum(:amount)
  end

  def balance_due
    amount - paid_amount
  end

  def mark_paid!(payment_method: nil)
    record_payment!(received_amount: balance_due.positive? ? balance_due : amount, payment_method: payment_method)
  end

  # Records money received against this fee. If it covers the remaining
  # balance the fee becomes fully paid, otherwise it's left partially paid.
  # Locks the row so concurrent partial payments can't race past each other.
  def record_payment!(received_amount:, payment_method: nil)
    transaction do
      lock!
      amount_to_record = [ received_amount.to_d, balance_due ].min
      raise ArgumentError, "amount must be positive" unless amount_to_record.positive?

      fee_payment_transactions.create!(
        amount: amount_to_record,
        payment_method: payment_method.presence || self.payment_method,
        paid_on: Date.current
      )

      update!(
        status: paid_amount >= amount ? :paid : :partially_paid,
        paid_on: Date.current,
        payment_method: payment_method.presence || self.payment_method
      )
    end
  end

  private

  # Paying the annual membership fee renews the member for another year.
  def extend_membership_renewal
    user.update!(renews_on: 1.year.from_now.to_date, membership_status: :active)
  end

  def assign_invoice_number
    return if invoice_number.present?

    loop do
      candidate = "INV-#{SecureRandom.hex(4).upcase}"
      unless FeePayment.exists?(invoice_number: candidate)
        self.invoice_number = candidate
        break
      end
    end
  end

  def fee_type_allowed_for_role
    return unless user && fee_type

    allowed = ALLOWED_FEE_TYPES[user.role]
    if allowed.nil? || !allowed.include?(fee_type)
      errors.add(:fee_type, "is not applicable for a #{user.role}")
    end
  end
end
