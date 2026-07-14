class Meeting < ApplicationRecord
  enum :meeting_type, { weekly: 0, monthly: 1, special: 2 }, default: :weekly

  belongs_to :chapter
  has_many :attendances, dependent: :nullify
  has_many :weekly_presentations, dependent: :nullify
  has_many :fee_payments, as: :feeable, dependent: :destroy
  has_many :expenses, as: :expenseable, dependent: :destroy
  has_many_attached :documents
  has_one_attached :payment_qr

  validates :scheduled_at, presence: true
  validates :fee_amount, numericality: { greater_than: 0 }, allow_nil: true

  after_create :notify_chapter_members

  def attendance_percentage
    total = chapter.members.count
    return 0 if total.zero?

    present = attendances.where(present: true).count
    ((present.to_f / total) * 100).round(1)
  end

  # Bulk version of attendance_percentage for lists of meetings within the same
  # chapter — avoids a chapter/members/attendances query per meeting.
  def self.attendance_percentages(meetings, chapter)
    total = chapter.members.count
    return Hash.new(0) if total.zero?

    present_counts = Attendance.where(meeting_id: meetings.map(&:id), present: true).group(:meeting_id).count
    meetings.each_with_object({}) do |meeting, hash|
      hash[meeting.id] = ((present_counts[meeting.id].to_i.to_f / total) * 100).round(1)
    end
  end

  def defaulters
    attended_ids = attendances.where(present: true).pluck(:user_id)
    chapter.members.where.not(id: attended_ids)
  end

  def paid_count
    fee_payments.paid.count
  end

  def pending_count
    fee_payments.pending.count
  end

  def collected_amount
    fee_payments.paid.sum(:amount)
  end

  def total_expenses
    expenses.sum(:amount)
  end

  def net_amount
    collected_amount - total_expenses
  end

  private

  def notify_chapter_members
    message = "A new #{meeting_type} meeting has been scheduled for #{scheduled_at.strftime('%d %b %Y %H:%M')}."
    message += " Fee: #{ActiveSupport::NumberHelper.number_to_currency(fee_amount)} — see the meeting page for payment details." if fee_amount.present?
    chapter.members.find_each { |member| member.notifications.create!(body: message) }
  end
end
