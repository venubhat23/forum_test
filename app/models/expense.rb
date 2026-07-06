class Expense < ApplicationRecord
  belongs_to :forum

  validates :category, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :incurred_on, presence: true
end
