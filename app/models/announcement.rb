class Announcement < ApplicationRecord
  enum :audience, { everyone: 0, specific_forum: 1, specific_plan: 2 }, default: :everyone

  belongs_to :forum, optional: true
  belongs_to :chapter, optional: true
  belongs_to :plan, optional: true
  belongs_to :created_by, class_name: "User"
  belongs_to :target_user, class_name: "User", optional: true

  validates :title, presence: true
  validates :body, presence: true
  validates :forum, presence: true, if: :specific_forum?
  validates :plan, presence: true, if: :specific_plan?

  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }

  def published?
    published_at.present? && published_at <= Time.current
  end

  def self.for_forum(forum)
    published.where(
      "audience = :everyone OR (audience = :specific_forum AND forum_id = :forum_id) OR (audience = :specific_plan AND plan_id = :plan_id)",
      everyone: audiences[:everyone], specific_forum: audiences[:specific_forum], forum_id: forum.id,
      specific_plan: audiences[:specific_plan], plan_id: forum.plan_id
    )
  end
end
