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
