class EventRegistration < ApplicationRecord
  enum :rsvp_status, { invited: 0, coming: 1, not_coming: 2 }, default: :invited

  belongs_to :event
  belongs_to :user
  has_one_attached :certificate

  validates :user_id, uniqueness: { scope: :event_id }
end
