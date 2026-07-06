class OneToOneMeeting < ApplicationRecord
  enum :status, { requested: 0, accepted: 1, rejected: 2, completed: 3 }, default: :requested

  belongs_to :forum
  belongs_to :requester, class_name: "User"
  belongs_to :requested_with, class_name: "User"

  validates :scheduled_at, presence: true
  validate :requester_and_requested_with_differ

  after_create :notify_requested_with

  private

  def requester_and_requested_with_differ
    errors.add(:requested_with, "must be a different member than the requester") if requester_id == requested_with_id
  end

  def notify_requested_with
    requested_with.notifications.create!(body: "#{requester.display_name} requested a one-to-one meeting with you.")
  end
end
