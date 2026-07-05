class Coupon < ApplicationRecord
  enum :discount_type, { percentage: 0, flat: 1 }, default: :percentage

  has_many :invoices, dependent: :nullify

  validates :code, presence: true, uniqueness: true
  validates :discount_value, numericality: { greater_than: 0 }
  validates :max_redemptions, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  before_validation { self.code = code.strip.upcase if code.present? }

  def redeemable?
    active? && (expires_on.nil? || expires_on >= Date.current) && (max_redemptions.nil? || times_redeemed < max_redemptions)
  end

  def discounted_amount(base)
    return base unless redeemable?

    if percentage?
      (base - (base * discount_value / 100.0)).round(2)
    else
      [ base - discount_value, 0 ].max
    end
  end
end
