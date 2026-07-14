class Event < ApplicationRecord
  enum :event_type, { seminar: 0, workshop: 1, training: 2, networking: 3 }, default: :networking

  belongs_to :forum
  has_many :event_registrations, dependent: :destroy
  has_many :registrants, through: :event_registrations, source: :user
  has_many :fee_payments, as: :feeable, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many_attached :gallery
  has_one_attached :payment_qr

  validates :title, presence: true
  validates :starts_at, presence: true
  validates :fee_amount, numericality: { greater_than: 0 }, allow_nil: true

  def registration_open?
    return true if registration_opens_at.blank? && registration_closes_at.blank?

    now = Time.current
    (registration_opens_at.blank? || now >= registration_opens_at) &&
      (registration_closes_at.blank? || now <= registration_closes_at)
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

  def attendance_percentage
    total = event_registrations.count
    return 0 if total.zero?

    ((event_registrations.where(attended: true).count.to_f / total) * 100).round(1)
  end

  def defaulters
    registrants.where(id: event_registrations.where(attended: false).select(:user_id))
  end
end
