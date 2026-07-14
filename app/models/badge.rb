class Badge < ApplicationRecord
  CATALOG = {
    "top_referrer" => { title: "Top Referrer", description: "Most referrals given in the chapter this month", icon: "bi-trophy" },
    "perfect_attendance" => { title: "Perfect Attendance", description: "Attended every chapter meeting this month", icon: "bi-calendar-check" },
    "hundred_k_club" => { title: "100k Club", description: "Generated ₹100,000+ in business this month", icon: "bi-cash-stack" }
  }.freeze

  belongs_to :user

  validates :key, inclusion: { in: CATALOG.keys }
  validates :key, uniqueness: { scope: [ :user_id, :period ] }

  def title
    CATALOG[key][:title]
  end

  def description
    CATALOG[key][:description]
  end

  def icon
    CATALOG[key][:icon]
  end
end
