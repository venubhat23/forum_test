class Event < ApplicationRecord
  enum :event_type, { seminar: 0, workshop: 1, training: 2, networking: 3 }, default: :networking

  belongs_to :forum
  has_many :event_registrations, dependent: :destroy
  has_many :registrants, through: :event_registrations, source: :user
  has_many_attached :gallery

  validates :title, presence: true
  validates :starts_at, presence: true

  def registration_open?
    return true if registration_opens_at.blank? && registration_closes_at.blank?

    now = Time.current
    (registration_opens_at.blank? || now >= registration_opens_at) &&
      (registration_closes_at.blank? || now <= registration_closes_at)
  end
end
