namespace :business_categories do
  desc "Seed the default Business Category / Speciality list into every forum (idempotent)"
  task seed_defaults: :environment do
    Forum.find_each do |forum|
      before = forum.business_categories.count
      BusinessCategory.seed_defaults_for(forum)
      after = forum.business_categories.count
      puts "#{forum.slug}: #{before} -> #{after} categories"
    end
  end
end
