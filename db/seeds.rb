# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

super_admin_email = ENV.fetch("SUPER_ADMIN_EMAIL", "admin@kramaconsultancy.com")
super_admin_password = ENV.fetch("SUPER_ADMIN_PASSWORD", "KramaAdmin123!")

super_admin = User.find_or_initialize_by(email: super_admin_email)
if super_admin.new_record?
  super_admin.password = super_admin_password
  super_admin.password_confirmation = super_admin_password
  super_admin.role = :super_admin
  super_admin.save!
  puts "Created Super Admin login -> email: #{super_admin_email}  password: #{super_admin_password}"
else
  puts "Super Admin already exists (#{super_admin_email})"
end

SAMPLE_PASSWORD = ENV.fetch("SAMPLE_USER_PASSWORD", "SamplePass123!")

default_plans = [
  { key: "bronze", name: "Bronze", price: 999, member_limit: 3, position: 0,
    features: [ "Up to 3 members", "Unlimited chapters", "Community support" ] },
  { key: "gold", name: "Gold", price: 2499, member_limit: 6, position: 1,
    features: [ "Up to 6 members", "Unlimited chapters", "Priority support" ] },
  { key: "diamond", name: "Diamond", price: 4999, member_limit: nil, position: 2,
    features: [ "Unlimited members", "Unlimited chapters", "Dedicated support" ] }
]

default_plans.each do |attrs|
  plan = Plan.find_or_initialize_by(key: attrs[:key])
  plan.assign_attributes(attrs.except(:key)) if plan.new_record?
  plan.save!
end
puts "Plans ready: #{Plan.ordered.pluck(:key).join(', ')}"

sample_forums = [
  {
    name: "Riverside Traders Association",
    slug: "riverside-traders",
    status: :active,
    plan_key: "gold",
    chapters: [ "Downtown", "Harborview", "North Ridge" ]
  },
  {
    name: "Metro Business Guild",
    slug: "metro-business-guild",
    status: :trial,
    plan_key: "gold",
    chapters: [ "Uptown", "Westside" ]
  },
  {
    name: "Coastal Merchants Network",
    slug: "coastal-merchants",
    status: :suspended,
    plan_key: "bronze",
    chapters: [ "Old Town" ]
  }
]

sample_forums.each do |forum_attrs|
  forum = Forum.find_or_initialize_by(slug: forum_attrs[:slug])
  forum.name = forum_attrs[:name]
  forum.status = forum_attrs[:status]
  forum.plan = Plan.find_by!(key: forum_attrs[:plan_key])
  forum.save!
  puts "Forum ready: #{forum.name} (#{forum.slug}) [#{forum.status}]"

  chapters = forum_attrs[:chapters].map do |chapter_name|
    chapter = Chapter.find_or_initialize_by(forum: forum, name: chapter_name)
    chapter.status ||= :active
    chapter.save!
    chapter
  end

  forum_admin_email = "admin@#{forum_attrs[:slug]}.example.com"
  forum_admin = User.find_or_initialize_by(email: forum_admin_email)
  if forum_admin.new_record?
    forum_admin.password = SAMPLE_PASSWORD
    forum_admin.password_confirmation = SAMPLE_PASSWORD
    forum_admin.role = :forum_admin
    forum_admin.forum = forum
    forum_admin.save!
  end

  chapters.each_with_index do |chapter, index|
    chapter_admin_email = "chapter-admin-#{index + 1}@#{forum_attrs[:slug]}.example.com"
    chapter_admin = User.find_or_initialize_by(email: chapter_admin_email)
    if chapter_admin.new_record?
      chapter_admin.password = SAMPLE_PASSWORD
      chapter_admin.password_confirmation = SAMPLE_PASSWORD
      chapter_admin.role = :chapter_admin
      chapter_admin.forum = forum
      chapter_admin.chapter = chapter
      chapter_admin.save!
    end

    committee_email = "committee-#{index + 1}@#{forum_attrs[:slug]}.example.com"
    committee_member = User.find_or_initialize_by(email: committee_email)
    if committee_member.new_record?
      committee_member.password = SAMPLE_PASSWORD
      committee_member.password_confirmation = SAMPLE_PASSWORD
      committee_member.role = :committee_member
      committee_member.forum = forum
      committee_member.chapter = chapter
      committee_member.full_name = "Committee Member #{index + 1}"
      committee_member.phone = "90000000#{index + 1}0"
      committee_member.designation = User::DESIGNATIONS[index % User::DESIGNATIONS.size]
      committee_member.save!
    end

    2.times do |member_index|
      member_email = "member-#{index + 1}-#{member_index + 1}@#{forum_attrs[:slug]}.example.com"
      member = User.find_or_initialize_by(email: member_email)
      if member.new_record?
        member.password = SAMPLE_PASSWORD
        member.password_confirmation = SAMPLE_PASSWORD
        member.role = :member
        member.forum = forum
        member.chapter = chapter
        member.full_name = "Sample Member #{index + 1}-#{member_index + 1}"
        member.phone = "91000000#{index + 1}#{member_index + 1}"
        member.save!
      end
    end
  end

  guest_email = "guest@#{forum_attrs[:slug]}.example.com"
  guest = User.find_or_initialize_by(email: guest_email)
  if guest.new_record?
    guest.password = SAMPLE_PASSWORD
    guest.password_confirmation = SAMPLE_PASSWORD
    guest.role = :guest
    guest.forum = forum
    guest.chapter = chapters.first
    guest.full_name = "Guest User"
    guest.phone = "9200000000"
    guest.nature_of_business = "Retail"
    guest.save!
  end
end

puts "Seeding complete. Sample user password: #{SAMPLE_PASSWORD}"
