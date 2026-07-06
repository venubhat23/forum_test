class Meeting < ApplicationRecord
  enum :meeting_type, { weekly: 0, monthly: 1, special: 2 }, default: :weekly

  belongs_to :chapter
  has_many :attendances, dependent: :nullify
  has_many_attached :documents

  validates :scheduled_at, presence: true

  after_create :notify_chapter_members

  def attendance_percentage
    total = chapter.members.count
    return 0 if total.zero?

    present = attendances.where(present: true).count
    ((present.to_f / total) * 100).round(1)
  end

  def defaulters
    attended_ids = attendances.where(present: true).pluck(:user_id)
    chapter.members.where.not(id: attended_ids)
  end

  private

  def notify_chapter_members
    message = "A new #{meeting_type} meeting has been scheduled for #{scheduled_at.strftime('%d %b %Y %H:%M')}."
    chapter.members.find_each { |member| member.notifications.create!(body: message) }
  end
end
