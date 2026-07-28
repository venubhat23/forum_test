class Attendance < ApplicationRecord
  enum :event_type, { meeting: 0, training: 1, event: 2 }
  enum :status, { not_marked: 0, attending: 1, attended: 2, absent: 3 }

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

  # For weekly meetings, `status` (not_marked -> attending -> attended/absent)
  # is the source of truth; keep `present` in sync so existing
  # reports/percentages that key off `present` don't need to change.
  before_validation :sync_present_from_status, if: :meeting?

  private

  def sync_present_from_status
    self.present = attended?
  end

  def event_type_allowed_for_role
    return unless user && event_type

    allowed = ALLOWED_EVENT_TYPES[user.role]
    if allowed.nil? || !allowed.include?(event_type)
      errors.add(:event_type, "is not applicable for a #{user.role}")
    end
  end
end
