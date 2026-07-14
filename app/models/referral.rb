class Referral < ApplicationRecord
  enum :status, { pending: 0, accepted: 1, rejected: 2, converted: 3 }

  belongs_to :forum, optional: true
  belongs_to :chapter, optional: true
  belongs_to :giver, class_name: "User", foreign_key: :referrer_id, inverse_of: :referrals_given
  belongs_to :receiver, class_name: "User", foreign_key: :referred_user_id, inverse_of: :referrals_received
  has_many :thanksgiving_slips, dependent: :destroy

  validate :giver_and_receiver_differ
  validate :giver_and_receiver_in_same_forum

  after_create :notify_receiver

  private

  def notify_receiver
    receiver.notifications.create!(body: "You received a new referral from #{giver.display_name}.")
  end

  def giver_and_receiver_differ
    return unless giver && receiver

    errors.add(:receiver, "must be a different member than the giver") if referrer_id == referred_user_id
  end

  def giver_and_receiver_in_same_forum
    return unless giver && receiver

    errors.add(:receiver, "must belong to the same forum as the giver") if giver.forum_id != receiver.forum_id
  end
end
