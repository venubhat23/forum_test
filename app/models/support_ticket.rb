class SupportTicket < ApplicationRecord
  enum :status, { open: 0, in_progress: 1, resolved: 2, closed: 3 }, default: :open
  enum :priority, { low: 0, medium: 1, high: 2 }, default: :medium

  belongs_to :forum, optional: true
  belongs_to :chapter, optional: true
  belongs_to :raised_by, class_name: "User"
  has_many :replies, class_name: "SupportTicketReply", dependent: :destroy

  validates :subject, presence: true
  validates :body, presence: true
end
