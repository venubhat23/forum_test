class Expense < ApplicationRecord
  belongs_to :forum
  belongs_to :expenseable, polymorphic: true, optional: true

  validates :category, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :incurred_on, presence: true
end
