class Meeting < ApplicationRecord
  enum :meeting_type, { weekly: 0, monthly: 1, special: 2 }, default: :weekly

  belongs_to :chapter
  has_many :attendances, dependent: :nullify
  has_many_attached :documents

  validates :scheduled_at, presence: true

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
end
