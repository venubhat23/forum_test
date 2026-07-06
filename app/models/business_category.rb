class BusinessCategory < ApplicationRecord
  belongs_to :forum
  belongs_to :parent, class_name: "BusinessCategory", optional: true
  has_many :children, class_name: "BusinessCategory", foreign_key: :parent_id, dependent: :destroy
  has_many :users, dependent: :nullify

  validates :name, presence: true

  scope :top_level, -> { where(parent_id: nil) }

  def top_level?
    parent_id.nil?
  end
end
