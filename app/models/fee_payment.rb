class FeePayment < ApplicationRecord
  enum :fee_type, { annual_membership: 0, meeting: 1, training: 2, event: 3 }
  enum :status, { pending: 0, paid: 1 }, default: :pending
  enum :payment_method, { cash: 0, bank_transfer: 1, upi: 2, cheque: 3, other: 4 }

  ALLOWED_FEE_TYPES = {
    "member" => %w[annual_membership meeting training event],
    "guest" => %w[meeting event]
  }.freeze

  belongs_to :user
  belongs_to :feeable, polymorphic: true, optional: true

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :fee_type, presence: true
  validates :invoice_number, uniqueness: true
  validate :fee_type_allowed_for_role

  before_validation :assign_invoice_number, on: :create
  after_save :extend_membership_renewal, if: -> { annual_membership? && paid? && saved_change_to_status? }

  def mark_paid!(payment_method: nil)
    update!(status: :paid, paid_on: Date.current, payment_method: payment_method || self.payment_method)
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
