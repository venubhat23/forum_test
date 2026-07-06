class MembershipApplication < ApplicationRecord
  enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :pending

  belongs_to :forum
  belongs_to :chapter, optional: true
  belongs_to :reviewed_by, class_name: "User", optional: true

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
