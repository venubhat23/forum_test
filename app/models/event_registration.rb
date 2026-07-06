class EventRegistration < ApplicationRecord
  belongs_to :event
  belongs_to :user
  has_one_attached :certificate

  validates :user_id, uniqueness: { scope: :event_id }
end
