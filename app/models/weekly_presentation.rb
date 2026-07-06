class WeeklyPresentation < ApplicationRecord
  belongs_to :chapter
  belongs_to :member, class_name: "User"
  belongs_to :meeting, optional: true
  has_one_attached :deck

  validates :topic, presence: true
  validates :scheduled_on, presence: true
end
