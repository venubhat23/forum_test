class OfficeDarshan < ApplicationRecord
  enum :status, { scheduled: 0, completed: 1, cancelled: 2 }, default: :scheduled

  belongs_to :forum
  belongs_to :member, class_name: "User"
  has_many_attached :photos

  validates :visit_date, presence: true
end
