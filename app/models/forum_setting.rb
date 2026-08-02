class ForumSetting < ApplicationRecord
  belongs_to :forum
  has_one_attached :logo

  TEMPLATES = {
    "classic"   => { name: "Classic", tagline: "Bold purple gradient hero with rounded cards.", swatches: %w[#6366f1 #764ba2 #f8fafc] },
    "modern"    => { name: "Modern", tagline: "Crisp light layout, navy hero panel, sky-blue accents.", swatches: %w[#0ea5e9 #0f172a #ffffff] },
    "minimal"   => { name: "Minimal", tagline: "Monochrome, generous whitespace, understated type.", swatches: %w[#111827 #6b7280 #ffffff] },
    "bold"      => { name: "Bold", tagline: "Light background, oversized type, vivid rose-to-orange energy.", swatches: %w[#f43f5e #fb923c #ffffff] },
    "elegant"   => { name: "Elegant", tagline: "Serif headings, ivory background, gold accent — premium feel.", swatches: %w[#b8860b #fffdf7 #1f2937] },
    "vibrant"   => { name: "Vibrant", tagline: "Playful multi-color gradient, rounded shapes, high energy.", swatches: %w[#ec4899 #8b5cf6 #fef9c3] },
    "corporate" => { name: "Corporate", tagline: "Structured, buttoned-up, navy-on-white professional look.", swatches: %w[#1d4ed8 #e2e8f0 #ffffff] },
    "warm"      => { name: "Warm", tagline: "Terracotta & cream, friendly and community-oriented.", swatches: %w[#ea580c #fef3e2 #7c2d12] }
  }.freeze
  DEFAULT_TEMPLATE = "classic"

  validates :forum_id, uniqueness: true

  def self.for(forum)
    find_or_create_by!(forum: forum)
  end

  def bank_details_present?
    bank_name.present? || bank_account_number.present?
  end

  # Guards reads/writes against website_template not existing yet on this
  # forum_settings row's DB connection (pending migration on a slow-to-
  # deploy environment) — public pages should never 500 mid-rollout.
  def website_template
    return DEFAULT_TEMPLATE unless self.class.column_names.include?("website_template")
    super.presence || DEFAULT_TEMPLATE
  end

  def website_template=(value)
    return unless self.class.column_names.include?("website_template")
    super
  end

  def template_info
    TEMPLATES.fetch(website_template, TEMPLATES[DEFAULT_TEMPLATE])
  end
end
