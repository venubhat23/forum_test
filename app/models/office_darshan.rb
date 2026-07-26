class OfficeDarshan < ApplicationRecord
  enum :status, { invited: 0, accepted: 1, declined: 2, completed: 3, cancelled: 4, scheduled: 5 }, default: :invited
  enum :scope, { member: 0, chapter: 1, forum_wide: 2 }, default: :member, prefix: :scope

  belongs_to :forum
  belongs_to :host, class_name: "User"
  belongs_to :visitor, class_name: "User", optional: true
  belongs_to :chapter, optional: true
  has_many :attendances, class_name: "OfficeDarshanAttendance", dependent: :destroy
  has_many :attendees, through: :attendances, source: :user
  has_many_attached :photos

  validates :scheduled_at, presence: true
  validate :host_and_visitor_differ, if: :scope_member?
  validate :visitor_present, if: :scope_member?
  validate :chapter_present, if: :scope_chapter?

  before_save :set_confirmed_at
  after_create :notify_visitor, if: -> { invited? && visitor_id.present? }
  after_create :broadcast_invites
  after_update :notify_on_status_change, if: -> { saved_change_to_status? && visitor_id.present? }

  def coming_count
    attendances.count(&:coming?)
  end

  def pending_count
    attendances.count(&:invited?)
  end

  def declined_count
    attendances.count(&:not_coming?)
  end

  def attendance_rate
    total = attendances.count
    return 0 if total.zero?

    ((coming_count.to_f / total) * 100).round(1)
  end

  private

  def host_and_visitor_differ
    errors.add(:visitor, "must be a different member than the host") if visitor_id.present? && host_id == visitor_id
  end

  def visitor_present
    errors.add(:visitor, "must be selected for a single-member invite") if visitor_id.blank?
  end

  def chapter_present
    errors.add(:chapter, "must be selected for a chapter-wide invite") if chapter_id.blank?
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

  def broadcast_invites
    targets = invite_targets
    return if targets.empty?

    targets.each { |user| attendances.find_or_create_by(user: user) }
  end

  def invite_targets
    case scope
    when "member"
      visitor ? [ visitor ] : []
    when "chapter"
      chapter ? chapter.users.where(role: [ :member, :committee_member ]).where.not(id: host_id) : []
    when "forum_wide"
      forum.users.where(role: [ :member, :committee_member ]).where.not(id: host_id)
    end
  end
end
