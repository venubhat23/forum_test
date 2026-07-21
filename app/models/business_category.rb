class BusinessCategory < ApplicationRecord
  belongs_to :forum
  belongs_to :parent, class_name: "BusinessCategory", optional: true
  has_many :children, -> { order(:name) }, class_name: "BusinessCategory", foreign_key: :parent_id, dependent: :destroy
  has_many :users, dependent: :nullify

  validates :name, presence: true

  scope :top_level, -> { where(parent_id: nil) }

  # Starter category => [specialities] list used to seed a forum's Business Categories
  # the first time (see .seed_defaults_for). After that, forum/super admins manage the
  # list themselves from Forum > Business Categories.
  DEFAULT_CATEGORIES = {
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

  def self.seed_defaults_for(forum)
    DEFAULT_CATEGORIES.each do |category_name, specialities|
      category = forum.business_categories.find_or_create_by!(name: category_name, parent_id: nil)
      specialities.each do |speciality_name|
        forum.business_categories.find_or_create_by!(name: speciality_name, parent_id: category.id)
      end
    end
  end

  def top_level?
    parent_id.nil?
  end
end
