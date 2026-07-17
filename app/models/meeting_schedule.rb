class MeetingSchedule < ApplicationRecord
  DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze
  MIN_MONTHS = 2
  MAX_MONTHS = 4

  belongs_to :chapter
  belongs_to :created_by, class_name: "User"
  # No `dependent:` option here on purpose: dependent callbacks (e.g. :nullify) run
  # in declaration order, which would fire before the custom before_destroy below and
  # wipe meeting_schedule_id on every occurrence before clear_meetings gets to inspect
  # scheduled_at — silently orphaning future occurrences instead of destroying them.
  has_many :meetings
  has_many :meeting_schedule_attendees, dependent: :destroy
  has_many :attendees, through: :meeting_schedule_attendees, source: :user

  validates :day_of_week, inclusion: { in: 0..6 }
  validates :start_time, :end_time, :start_date, :end_date, presence: true
  validate :end_time_after_start_time
  validate :end_date_within_range

  after_create :generate_meetings!
  after_create :notify_attendees

  before_destroy :clear_meetings

  def day_name
    DAY_NAMES[day_of_week]
  end

  def occurrence_dates
    return [] if start_date.blank? || end_date.blank? || day_of_week.blank?

    dates = []
    date = start_date + ((day_of_week - start_date.wday) % 7)
    while date <= end_date
      dates << date
      date += 7
    end
    dates
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, "must be after the start time") if end_time <= start_time
  end

  def end_date_within_range
    return if start_date.blank? || end_date.blank?

    if end_date <= start_date
      errors.add(:end_date, "must be after the start date")
      return
    end

    min_end = start_date + MIN_MONTHS.months
    max_end = start_date + MAX_MONTHS.months
    if end_date < min_end
      errors.add(:end_date, "must be at least #{MIN_MONTHS} months after the start date")
    elsif end_date > max_end
      errors.add(:end_date, "must be at most #{MAX_MONTHS} months after the start date")
    end
  end

  def generate_meetings!
    occurrence_dates.each do |date|
      meetings.create!(
        chapter: chapter,
        meeting_type: :weekly,
        scheduled_at: Time.zone.local(date.year, date.month, date.day, start_time.hour, start_time.min),
        venue: venue,
        agenda: agenda
      )
    end
  end

  def notify_attendees
    return if attendees.none?

    message = "You've been invited to a new recurring meeting schedule" \
      "#{" \"#{title}\"" if title.present?}: every #{day_name}, " \
      "#{start_time.strftime('%I:%M %p')}–#{end_time.strftime('%I:%M %p')}, " \
      "from #{start_date.strftime('%d %b %Y')} to #{end_date.strftime('%d %b %Y')}" \
      "#{" at #{venue}" if venue.present?}."
    attendees.find_each { |user| user.notifications.create!(body: message) }
  end

  def clear_meetings
    meetings.where("scheduled_at > ?", Time.current).destroy_all
    meetings.where("scheduled_at <= ?", Time.current).update_all(meeting_schedule_id: nil)
  end
end
