class MembershipApplication < ApplicationRecord
  enum :status, { pending: 0, approved: 1, rejected: 2 }, default: :pending

  has_secure_token :token

  belongs_to :forum
  belongs_to :chapter, optional: true
  belongs_to :reviewed_by, class_name: "User", optional: true
  belongs_to :user, optional: true
  belongs_to :invited_by, class_name: "User", optional: true

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  after_create :notify_forum_admins

  private

  def notify_forum_admins
    forum.users.where(role: [ :forum_admin, :chapter_admin ]).find_each do |admin|
      admin.notifications.create!(body: "New membership application from #{name}#{" (#{company_name})" if company_name.present?}.")
    end
  end
end
