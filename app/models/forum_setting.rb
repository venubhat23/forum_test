class ForumSetting < ApplicationRecord
  belongs_to :forum
  has_one_attached :logo

  validates :forum_id, uniqueness: true

  def self.for(forum)
    find_or_create_by!(forum: forum)
  end
end
