class Forum < ApplicationRecord
  enum :status, { trial: 0, active: 1, suspended: 2, expired: 3, archived: 4 }, default: :active

  RESERVED_SLUGS = %w[
    super_admin users dashboard impersonation forum_requests up rails
    assets packs cable admin api f new edit create update destroy
  ].freeze

  belongs_to :plan

  has_many :chapters, dependent: :destroy
  has_many :users, dependent: :nullify
  has_many :business_categories, dependent: :destroy
  has_many :one_to_one_meetings, dependent: :destroy
  has_many :office_darshans, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :membership_applications, dependent: :destroy
  has_many :membership_plans, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_one :forum_setting, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9\-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" },
    exclusion: { in: RESERVED_SLUGS, message: "is reserved and can't be used" }

  before_validation :generate_slug, on: :create
  before_validation :assign_default_plan, on: :create
  before_validation :assign_subscription_dates, on: :create

  def admin
    users.find_by(role: :forum_admin)
  end

  def member_limit
    plan&.member_limit
  end

  def member_limit_reached?
    member_limit.present? && users.member.count >= member_limit
  end

  def trial_days_left
    return nil unless trial_ends_at
    (trial_ends_at.to_date - Date.current).to_i
  end

  def days_to_renewal
    return nil unless renews_on
    (renews_on - Date.current).to_i
  end

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?
    return if name.blank?

    base = name.parameterize
    candidate = base
    counter = 1
    while Forum.exists?(slug: candidate) || RESERVED_SLUGS.include?(candidate)
      counter += 1
      candidate = "#{base}-#{counter}"
    end
    self.slug = candidate
  end

  def assign_default_plan
    self.plan ||= Plan.ordered.active.first
  end

  def assign_subscription_dates
    self.started_at ||= Time.current
    self.trial_ends_at ||= started_at + plan.trial_days.days if trial? && plan && plan.trial_days.to_i.positive?
    self.renews_on ||= started_at.to_date + (plan&.annual? ? 1.year : 1.month)
  end
end
