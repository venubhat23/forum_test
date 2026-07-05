class ThanksgivingSlip < ApplicationRecord
  belongs_to :referral
  belongs_to :given_by, class_name: "User"

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :given_by_is_the_receiver

  private

  def given_by_is_the_receiver
    return unless referral && given_by

    errors.add(:given_by, "must be the member who received the referral") if given_by_id != referral.receiver_id
  end
end
