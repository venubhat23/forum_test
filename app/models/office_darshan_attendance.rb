class OfficeDarshanAttendance < ApplicationRecord
  belongs_to :office_darshan
  belongs_to :user

  enum :rsvp_status, { invited: 0, coming: 1, not_coming: 2 }, default: :invited

  validates :user_id, uniqueness: { scope: :office_darshan_id }
  validates :rating, inclusion: { in: 1..5 }, allow_nil: true

  after_create :notify_invitee, unless: -> { office_darshan.scope_member? }

  def reviewed?
    reviewed_at.present?
  end

  private

  def notify_invitee
    user.notifications.create!(body: "#{office_darshan.host.display_name} invited you to an office darshan visit (#{office_darshan.forum.name}). Let them know if you're coming.")
  end
end
