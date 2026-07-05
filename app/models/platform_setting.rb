class PlatformSetting < ApplicationRecord
  belongs_to :default_plan, class_name: "Plan", optional: true

  validates :site_name, presence: true
  validates :currency, presence: true
  validates :invoice_prefix, presence: true
  validates :tax_percent, numericality: { greater_than_or_equal_to: 0 }

  def self.instance
    first_or_create!(site_name: "Krama Consultancy", support_email: "support@kramaconsultancy.com")
  end
end
