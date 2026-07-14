class ThanksgivingSlip < ApplicationRecord
  belongs_to :referral
  belongs_to :given_by, class_name: "User"
  has_one_attached :proof

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :given_by_is_the_receiver

  after_create :mark_referral_converted

  private

  def mark_referral_converted
    referral.update_column(:status, Referral.statuses[:converted])
  end

  def given_by_is_the_receiver
    return unless referral && given_by

    errors.add(:given_by, "must be the member who received the referral") if given_by_id != referral.referred_user_id
  end
end
