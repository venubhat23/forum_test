class Attendance < ApplicationRecord
  enum :event_type, { meeting: 0, training: 1, event: 2 }

  ALLOWED_EVENT_TYPES = {
    "member" => %w[meeting training event],
    "guest" => %w[meeting event]
  }.freeze

  belongs_to :user
  belongs_to :meeting, optional: true
  belongs_to :event, optional: true

  validates :event_type, presence: true
  validates :occurred_on, presence: true
  validate :event_type_allowed_for_role

  private

  def event_type_allowed_for_role
    return unless user && event_type

    allowed = ALLOWED_EVENT_TYPES[user.role]
    if allowed.nil? || !allowed.include?(event_type)
      errors.add(:event_type, "is not applicable for a #{user.role}")
    end
  end
end
