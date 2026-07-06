class Notification < ApplicationRecord
  belongs_to :user

  validates :body, presence: true

  scope :unread, -> { where(read_at: nil) }

  def read?
    read_at.present?
  end

  def mark_read!
    update_column(:read_at, Time.current) unless read?
  end
end
