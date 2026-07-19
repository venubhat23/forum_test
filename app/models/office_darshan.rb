class OfficeDarshan < ApplicationRecord
  enum :status, { invited: 0, accepted: 1, declined: 2, completed: 3, cancelled: 4 }, default: :invited

  belongs_to :forum
  belongs_to :host, class_name: "User"
  belongs_to :visitor, class_name: "User"
  has_many_attached :photos

  validates :scheduled_at, presence: true
  validate :host_and_visitor_differ

  before_save :set_confirmed_at
  after_create :notify_visitor, if: :invited?
  after_update :notify_on_status_change, if: :saved_change_to_status?

  private

  def host_and_visitor_differ
    errors.add(:visitor, "must be a different member than the host") if host_id == visitor_id
  end

  def set_confirmed_at
    self.confirmed_at ||= Time.current if status_changed? && (accepted? || completed?)
  end

  def notify_visitor
    visitor.notifications.create!(body: "#{host.display_name} invited you to visit their office on #{scheduled_at.strftime('%d %b %Y %H:%M')}.")
  end

  def notify_on_status_change
    case status
    when "accepted"
      host.notifications.create!(body: "#{visitor.display_name} accepted your office darshan invite for #{scheduled_at.strftime('%d %b %Y %H:%M')}.")
    when "declined"
      host.notifications.create!(body: "#{visitor.display_name} declined your office darshan invite.")
    end
  end
end
