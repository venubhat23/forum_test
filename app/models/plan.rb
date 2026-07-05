class Plan < ApplicationRecord
  enum :billing_cycle, { monthly: 0, annual: 1 }, default: :monthly
  enum :status, { active: 0, archived: 1 }, default: :active

  has_many :forums, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true, format: { with: /\A[a-z0-9_]+\z/, message: "can only contain lowercase letters, numbers, and underscores" }
  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :member_limit, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :trial_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position, :name) }

  def unlimited_members?
    member_limit.nil?
  end
end
