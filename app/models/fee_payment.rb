class FeePayment < ApplicationRecord
  enum :fee_type, { annual_membership: 0, meeting: 1, training: 2, event: 3 }
  enum :status, { pending: 0, paid: 1 }, default: :pending

  ALLOWED_FEE_TYPES = {
    "member" => %w[annual_membership meeting training event],
    "guest" => %w[meeting event]
  }.freeze

  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :fee_type, presence: true
  validate :fee_type_allowed_for_role

  def mark_paid!
    update!(status: :paid, paid_on: Date.current)
  end

  private

  def fee_type_allowed_for_role
    return unless user && fee_type

    allowed = ALLOWED_FEE_TYPES[user.role]
    if allowed.nil? || !allowed.include?(fee_type)
      errors.add(:fee_type, "is not applicable for a #{user.role}")
    end
  end
end
