class Referral < ApplicationRecord
  enum :referral_type, { self_referral: 0, outside_referral: 1 }

  belongs_to :giver, class_name: "User"
  belongs_to :receiver, class_name: "User"
  has_many :thanksgiving_slips, dependent: :destroy

  validates :prospect_name, presence: true
  validates :referral_type, presence: true
  validate :giver_and_receiver_differ
  validate :giver_and_receiver_in_same_forum

  private

  def giver_and_receiver_differ
    return unless giver && receiver

    errors.add(:receiver, "must be a different member than the giver") if giver_id == receiver_id
  end

  def giver_and_receiver_in_same_forum
    return unless giver && receiver

    errors.add(:receiver, "must belong to the same forum as the giver") if giver.forum_id != receiver.forum_id
  end
end
