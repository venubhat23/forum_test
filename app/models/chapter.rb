class Chapter < ApplicationRecord
  enum :status, { active: 0, inactive: 1 }, default: :active

  belongs_to :forum
  has_many :users, dependent: :nullify
  has_many :members, -> { where(role: :member) }, class_name: "User"
  has_many :guests, -> { where(role: :guest) }, class_name: "User"
  has_many :committee_members, -> { where(role: :committee_member) }, class_name: "User"
  has_many :meetings, dependent: :destroy
  has_many :meeting_schedules, dependent: :destroy
  has_many :weekly_presentations, dependent: :destroy
  has_many :events, dependent: :nullify
  has_many :announcements, dependent: :nullify
  has_many :support_tickets, dependent: :nullify
  has_many :membership_applications, dependent: :nullify
  has_many :referrals, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :forum_id }
  validate :within_forum_chapter_limit, on: :create

  def collected_amount
    FeePayment.joins(:user).where(users: { chapter_id: id }, status: :paid).sum(:amount)
  end

  # Permanently deletes the chapter and every member/guest/committee-member
  # in it (and everything belonging to them), plus the chapter's own
  # dependent records (meetings, meeting_schedules, weekly_presentations).
  def purge!
    ActiveRecord::Base.transaction do
      users.find_each(&:purge!)
      destroy!
    end
  end

  private

  def within_forum_chapter_limit
    return unless forum

    if forum.chapter_limit_reached?
      errors.add(:base, "#{forum.name} has reached its #{forum.plan.name} plan limit of #{forum.chapter_limit} chapters. Ask your platform admin to upgrade the plan.")
    end
  end
end
