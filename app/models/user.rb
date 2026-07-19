class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { super_admin: 0, forum_admin: 1, chapter_admin: 2, committee_member: 3, member: 4, guest: 5, admin: 6, accountant: 7, support_staff: 8 }
  enum :membership_status, { pending: 0, active: 1, suspended: 2 }, prefix: :membership

  # Internal (Krama Consultancy staff) roles: not tied to any Forum tenant, managed from super_admin/users.
  INTERNAL_ROLES = %w[super_admin admin accountant support_staff].freeze

  DESIGNATIONS = [ "President", "Vice President", "Associate Vice President", "Secretary", "Treasurer", "Coordinator" ].freeze

  # Category => list of specialities. Speciality dropdowns cascade off the chosen category
  # (see app/javascript/controllers/business_category_controller.js).
  BUSINESS_CATEGORIES = {
    "Advertising & Marketing" => [
      "Advertising & Marketing (Other)", "Branding", "Copywriter/Writer", "Digital Marketing", "Embroidery",
      "Graphic Designer", "Home Automation", "Marketing Consultant", "Media Services / Entertainment",
      "Offset Printer", "Photographer - Commercial", "Photographer / Videographer", "Print Advertising",
      "Printing & Packaging", "Promotional Products", "Public Relations", "Publisher", "Radio Advertising",
      "Relationship Marketing", "Signage Company", "Television Advertising", "Videographer / Film Producer",
      "Web Design", "Website Development", "Other"
    ],
    "Agriculture" => [ "Farm Equipment / Machinery", "Other" ],
    "Animals" => [ "Veterinarian", "Other" ],
    "Architecture & Engineering" => [
      "Architect", "Civil / Structural Engineer", "Feng Shui", "Garden & Landscape Architect",
      "Industrial Automation", "Interior Architecture", "Landscape services", "Surveyor",
      "Vaastu Consultant", "Other"
    ],
    "Art & Entertainment" => [ "Artist", "Disk Jockey (DJ)", "Entertainer", "Musicians", "Other" ],
    "Car & Motorcycle" => [
      "Auto / Car Body Shop", "Auto / Car Detailing", "Auto / Car Parts & Accessories",
      "Auto / Car Rental / Leasing", "Auto/Car Repair / Servicing", "Auto/Car Sales",
      "Commercial Vehicle Dealers", "Driving Instructor", "Gas Station", "Motorcycle - Sales & Service",
      "Tyre Sales / Replacement", "Other"
    ],
    "Computer & Programming" => [
      "App Developer", "Cloud Services", "Computer Repair", "Computer Retailer", "Computer Software",
      "Data Security", "ERP Software", "IT & Network", "IT Consultant", "Programmer", "Other"
    ],
    "Construction" => [
      "Borewell Dealer", "Bricklayer / Stonemason", "Builder / General Contractor / Materials", "Carpenter",
      "Civil Contractor", "Commercial Builder", "Construction", "Demolition Contractors", "Earth Movers",
      "Electrical Contractor", "Elevators & Escalators", "Energy Services", "Environmental Services",
      "Fabrication", "Flooring", "Glass Dealer", "Hardware Dealer", "Hollow Blocks Supplier",
      "HVAC - Heating & Air", "Interior Designer / Decorator", "Kitchen Construction", "Land Scaping",
      "Metal work", "Painter", "Pest Control", "Plumbing", "Pool, Spas & Saunas", "Other"
    ],
    "Consulting" => [
      "Business Broker", "Business - Consultant", "Business - Management",
      "Business - Organisation & Process", "Business - Quality Management", "Business - Small Business"
    ],
    "Employment Activities" => [
      "Administrative Services", "Employment Agency", "Human Resources", "Recruiter", "Other"
    ],
    "Event & Business Service" => [
      "Call Center / Answering Service", "Corporate Events", "Event & Business-Service (Other)",
      "Event Management Company", "Event Manager / Marketer", "Event Planner", "Event Rentals",
      "Event Venue / Room Rental", "Hotel / Resorts", "Office Services", "Technicians - Audio, Video",
      "Translator / Language Services", "Other"
    ],
    "Finance & Insurance" => [
      "Banking Services", "Finance & Insurance (Other)", "Financial Advisor", "Financial Consultant",
      "Foreign Exchange", "General Insurance", "Health Insurance", "Insurance - Life, Health, General",
      "Life Insurance", "Loan Providers", "Mutual Funds", "Property Construction Loan", "Stock Broker",
      "Business Financing", "Collections", "Commercial Insurance", "Credit Card / Merchant Services",
      "Credit Repair", "Insurance Adjuster", "Pensions", "Residential Mortgages", "Other"
    ],
    "Food & Beverage" => [
      "Bakery & Food products", "Caterer", "Chocolatier", "Food & Beverage (Other)",
      "Food Product Manufacturer", "Home made Food Products", "Processed / Packaged Food products",
      "Restaurant", "Wine Merchant / Wine", "Other"
    ],
    "Health & Wellness" => [
      "Acupuncture", "Alternative Wellness", "Chiropractor", "Counselor / Psychotherapist", "Dentist",
      "Doctor/Physician", "Essential Oil", "Eye Care", "Health & Wellness Products",
      "Health & Wellness Services", "Health Facility / GYM / Club", "Hearing / Audiology", "Hospice",
      "Hypnotherapist", "In-Home Care", "Massage Therapist", "Medical Services / Pharma", "Naturopaths",
      "Nutritional Supplements", "Nutritionist", "Osteopath", "Othrodontist",
      "Personal Trainer - Fitness", "Pharamcist", "Physical Therapist", "Other"
    ],
    "Legal & Accounting" => [
      "Accounting Services - CA, Auditor", "Advocate / Lawyer", "Bookkeeping", "Business Law",
      "Certified Public Accountant (CPA)", "Civil Law", "Estate Planning", "Intellectual Property",
      "Legal Services", "Mediator", "Notary", "Payroll Service", "Tax Advisor", "Other"
    ],
    "Manufacturing" => [ "Apparel", "Manufacturing (product)", "Metal / SS Fabricator", "Packaging", "Other" ],
    "Organisation & Others" => [
      "Chambers / Associations", "NGO, non-profit organisation, CSR Co.", "Other"
    ],
    "Personal Services" => [
      "Astrologist", "Cosmetics/Skin Care", "Dry Cleaning / Laundry", "Funeral Planning / Services",
      "Physiotherapy", "Salon / Spa", "Senior Service Provider", "Other"
    ],
    "Real Estate Services" => [
      "Carpet, Upholstery Cleaner", "Cleaning Service", "Commercial Real Estate",
      "Electricity & Gas Dealers", "Farm Land Developer", "Land Developer", "Property Management",
      "Real Estate Consultant / Agent", "Real Estate Investments", "Real Estate Maintenance / Care Taker",
      "Real Estate Planning Consultant", "Waste Disposal", "Other"
    ],
    "Repair" => [ "Appliance Repair", "Furniture Repair / Upholstery", "Other" ],
    "Retail" => [
      "Appliances", "Art Dealer / Gallery Owner", "Bath Accessories", "Book Dealers", "Building Materials",
      "Cleaning Products", "Clothing & Accessories Retailer", "Cold Pressed Oil",
      "Construction Products Retail", "Custom Clothing / Tailor", "Diamonds / Gold / Silver Dealer",
      "Drinking Water Supplier", "Electronic Gadgets & Mobile accessories", "Environmental Products",
      "Fashion Designer", "Fashion Jewellery", "Florist", "Furniture Retailer", "Garments & Textiles",
      "Gifts - Corporate Gifting", "Groceries", "Home Appliances", "Home Theatres", "Lighting Retailers",
      "Makeup Artist", "Mattresses", "Office Equipment/Machines", "Office Furniture", "Office Supplies",
      "Pest Control", "Retail (Other)", "Sports Retailera", "Tiles / Sanitaryware", "Uniforms",
      "UPS & Battery", "Water Systems / RO Purifier", "Wood Merchants / Plywood etc", "Other"
    ],
    "Security & Investigation" => [
      "CCTV", "Fire Protection", "Investigative Services / Detective", "Locksmith",
      "Occupational Safety", "Security Personnel", "Security Systems", "Other"
    ],
    "Services" => [ "Facility Management Services", "Other" ],
    "Sports & Leisure" => [ "Martial Arts", "Sports & Leisure (Other)", "Yoga", "Other" ],
    "Telecommunications" => [ "Mobile Telecommunications", "Telecommunications Products/Services", "Other" ],
    "Training & Coaching" => [
      "Business Training / Coach", "Communication Coach", "Education Services/Tutor", "Leadership Coach",
      "Life Coach", "Management Coach", "Sales Training Coach", "Training & Coaching (Other)", "Other"
    ],
    "Transport & Shipping" => [
      "Courier", "Freight Service", "Mailing Service", "Moving Company / Logistics",
      "Shuttle / Limousine Service", "Other"
    ],
    "Travel" => [ "Ticketing", "Tours/Tour Guide", "Travel Agent", "Other" ]
  }.freeze

  has_one_attached :photo
  has_many_attached :kyc_documents

  belongs_to :forum, optional: true
  belongs_to :chapter, optional: true
  belongs_to :invited_by, class_name: "User", optional: true
  belongs_to :business_category_ref, class_name: "BusinessCategory", foreign_key: "business_category_id", optional: true
  belongs_to :membership_plan, optional: true
  has_many :invitees, class_name: "User", foreign_key: :invited_by_id, dependent: :nullify, inverse_of: :invited_by
  has_many :fee_payments, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :referrals_given, class_name: "Referral", foreign_key: :referrer_id, dependent: :destroy, inverse_of: :giver
  has_many :referrals_received, class_name: "Referral", foreign_key: :referred_user_id, dependent: :destroy, inverse_of: :receiver
  has_many :thanksgiving_slips_given, class_name: "ThanksgivingSlip", foreign_key: :given_by_id, dependent: :destroy, inverse_of: :given_by
  has_many :notifications, dependent: :destroy
  has_many :badges, dependent: :destroy
  has_many :created_leads, class_name: "Lead", foreign_key: :created_by_id, dependent: :destroy, inverse_of: :created_by
  has_many :accepted_leads, class_name: "Lead", foreign_key: :accepted_by_id, dependent: :nullify, inverse_of: :accepted_by
  has_many :lead_taggings, dependent: :destroy
  has_many :tagged_leads, through: :lead_taggings, source: :lead
  has_many :event_registrations, dependent: :destroy
  has_many :invited_event_registrations, class_name: "EventRegistration", foreign_key: :invited_by_id, dependent: :nullify, inverse_of: false
  has_many :weekly_presentations, foreign_key: :member_id, dependent: :destroy, inverse_of: :member
  has_many :office_darshans, foreign_key: :member_id, dependent: :destroy, inverse_of: :member
  has_many :one_to_one_meetings_as_requester, class_name: "OneToOneMeeting", foreign_key: :requester_id, dependent: :destroy, inverse_of: :requester
  has_many :one_to_one_meetings_as_requested, class_name: "OneToOneMeeting", foreign_key: :requested_with_id, dependent: :destroy, inverse_of: :requested_with
  has_many :membership_applications_reviewed, class_name: "MembershipApplication", foreign_key: :reviewed_by_id, dependent: :nullify, inverse_of: :reviewed_by
  has_many :support_tickets_raised, class_name: "SupportTicket", foreign_key: :raised_by_id, dependent: :destroy, inverse_of: :raised_by
  has_many :support_ticket_replies, dependent: :destroy
  has_many :announcements_created, class_name: "Announcement", foreign_key: :created_by_id, dependent: :destroy, inverse_of: :created_by
  has_many :targeted_announcements, class_name: "Announcement", foreign_key: :target_user_id, dependent: :nullify, inverse_of: :target_user
  has_many :payments_recorded, class_name: "Payment", foreign_key: :recorded_by_id, dependent: :destroy, inverse_of: :recorded_by

  validates :forum, presence: true, unless: -> { INTERNAL_ROLES.include?(role) }
  validates :chapter, presence: true, if: -> { member? || guest? || committee_member? }
  validates :full_name, presence: true, if: -> { member? || guest? || committee_member? }
  validates :phone, presence: true, if: -> { member? || guest? || committee_member? }
  validates :nature_of_business, presence: true, if: :guest?
  validates :designation, presence: true, if: :committee_member?
  validate :within_forum_member_limit, on: :create, if: :member?

  before_validation :assign_placeholder_password, if: -> { guest? && password.blank? }
  before_validation :ensure_session_token, on: :create
  before_save :capture_original_password, if: -> { password.present? }

  def display_name
    full_name.presence || email.split("@").first
  end

  def designation_rank
    rank = DESIGNATIONS.index(designation)
    rank.nil? ? DESIGNATIONS.size : rank
  end

  def internal?
    INTERNAL_ROLES.include?(role)
  end

  def suspended?
    suspended_at.present?
  end

  def suspend!
    update_column(:suspended_at, Time.current)
  end

  def unsuspend!
    update_column(:suspended_at, nil)
  end

  def force_logout!
    update_column(:session_token, SecureRandom.hex(32))
  end

  private

  def ensure_session_token
    self.session_token ||= SecureRandom.hex(32)
  end

  def within_forum_member_limit
    return unless forum

    if forum.member_limit_reached?
      errors.add(:base, "#{forum.name} has reached its #{forum.plan.name} plan limit of #{forum.member_limit} members. Ask your platform admin to upgrade the plan.")
    end
  end

  def assign_placeholder_password
    generated = SecureRandom.hex(12)
    self.password = generated
    self.password_confirmation = generated
  end

  def capture_original_password
    self.original_password = password
  end
end
