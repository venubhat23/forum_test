class Document < ApplicationRecord
  belongs_to :forum
  belongs_to :documentable, polymorphic: true, optional: true
  has_one_attached :file

  validates :title, presence: true
end
