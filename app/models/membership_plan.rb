class MembershipPlan < ApplicationRecord
  enum :cycle, { monthly: 0, annual: 1, corporate: 2, student: 3, lifetime: 4 }, default: :annual

  belongs_to :forum
  has_many :users, dependent: :nullify

  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
