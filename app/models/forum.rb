class Forum < ApplicationRecord
  enum :status, { trial: 0, active: 1, suspended: 2, expired: 3 }, default: :active

  has_many :chapters, dependent: :destroy
  has_many :users, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A[a-z0-9\-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, on: :create

  def admin
    users.find_by(role: :forum_admin)
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
