class Lead < ApplicationRecord
  STAGE_ORDER = %w[requested accepted consulting doing_business converted].freeze
  MANUALLY_ADVANCEABLE_STAGES = %w[consulting doing_business].freeze

  enum :stage, { requested: 0, accepted: 1, consulting: 2, doing_business: 3, converted: 4, declined: 5 }

  belongs_to :forum
  belongs_to :created_by, class_name: "User"
  belongs_to :accepted_by, class_name: "User", optional: true
  has_many :lead_taggings, dependent: :destroy
  has_many :tagged_users, through: :lead_taggings, source: :user
  has_one_attached :thanksgiving_proof

  validates :prospect_name, presence: true
  validates :thanksgiving_amount, numericality: { greater_than: 0, less_than_or_equal_to: 99_999_999.99 }, allow_nil: true

  def claimed?
    accepted_by_id.present?
  end

  def claimable_by?(user)
    !claimed? && tagged_users.include?(user)
  end

  # Atomically claims the lead so two tagged members racing to accept it
  # can't both succeed. Returns false if someone else got there first.
  def claim!(user)
    updated = self.class.where(id: id, accepted_by_id: nil).update_all(
      accepted_by_id: user.id, accepted_at: Time.current, stage: self.class.stages[:accepted]
    )
    reload if updated == 1
    updated == 1
  end

  def release!
    update!(accepted_by_id: nil, accepted_at: nil, stage: :requested)
  end

  def next_stage
    idx = STAGE_ORDER.index(stage)
    return nil if idx.nil? || idx == STAGE_ORDER.size - 1
    STAGE_ORDER[idx + 1]
  end
end
