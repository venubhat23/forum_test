class Chapter < ApplicationRecord
  enum :status, { active: 0, inactive: 1 }, default: :active

  belongs_to :forum
  has_many :users, dependent: :nullify
  has_many :members, -> { where(role: :member) }, class_name: "User"
  has_many :guests, -> { where(role: :guest) }, class_name: "User"
  has_many :committee_members, -> { where(role: :committee_member) }, class_name: "User"

  validates :name, presence: true, uniqueness: { scope: :forum_id }
end
