class Chapter < ApplicationRecord
  enum :status, { active: 0, inactive: 1 }, default: :active

  belongs_to :forum
  has_many :users, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :forum_id }
end
