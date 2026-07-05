class Forum < ApplicationRecord
  enum :status, { trial: 0, active: 1, suspended: 2, expired: 3 }, default: :active
  enum :plan, { bronze: 0, gold: 1, diamond: 2 }, default: :bronze

  PLANS = {
    bronze: { label: "Bronze", member_limit: 3, features: [ "Up to 3 members", "Unlimited chapters", "Community support" ] },
    gold: { label: "Gold", member_limit: 6, features: [ "Up to 6 members", "Unlimited chapters", "Priority support" ] },
    diamond: { label: "Diamond", member_limit: nil, features: [ "Unlimited members", "Unlimited chapters", "Dedicated support" ] }
  }.freeze

  has_many :chapters, dependent: :destroy
  has_many :users, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9\-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, on: :create

  def admin
    users.find_by(role: :forum_admin)
  end

  def plan_details
    PLANS.fetch(plan.to_sym)
  end

  def member_limit
    plan_details[:member_limit]
  end

  def member_limit_reached?
    member_limit.present? && users.member.count >= member_limit
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
    while Forum.exists?(slug: candidate)
      counter += 1
      candidate = "#{base}-#{counter}"
    end
    self.slug = candidate
  end
end
