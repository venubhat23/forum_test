class ForumSetting < ApplicationRecord
  belongs_to :forum
  has_one_attached :logo

  validates :forum_id, uniqueness: true

  def self.for(forum)
    find_or_create_by!(forum: forum)
  end

  def bank_details_present?
    bank_name.present? || bank_account_number.present?
  end
end
