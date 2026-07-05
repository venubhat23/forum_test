class AddPlanReferenceToForums < ActiveRecord::Migration[8.0]
  class MigrationPlan < ActiveRecord::Base
    self.table_name = "plans"
  end

  class MigrationForum < ActiveRecord::Base
    self.table_name = "forums"
  end

  PLAN_SEED = {
    0 => { key: "bronze", name: "Bronze", price: 999, member_limit: 3,
           features: [ "Up to 3 members", "Unlimited chapters", "Community support" ] },
    1 => { key: "gold", name: "Gold", price: 2499, member_limit: 6,
           features: [ "Up to 6 members", "Unlimited chapters", "Priority support" ] },
    2 => { key: "diamond", name: "Diamond", price: 4999, member_limit: nil,
           features: [ "Unlimited members", "Unlimited chapters", "Dedicated support" ] }
  }.freeze

  def up
    add_reference :forums, :plan, foreign_key: true

    plan_ids_by_index = {}
    PLAN_SEED.each do |index, attrs|
      plan = MigrationPlan.find_or_create_by!(key: attrs[:key]) do |p|
        p.name = attrs[:name]
        p.price = attrs[:price]
        p.member_limit = attrs[:member_limit]
        p.features = attrs[:features]
        p.billing_cycle = 0
        p.trial_days = 14
        p.status = 0
        p.position = index
      end
      plan_ids_by_index[index] = plan.id
    end

    MigrationForum.reset_column_information
    MigrationForum.find_each do |forum|
      plan_id = plan_ids_by_index[forum.read_attribute(:plan)] || plan_ids_by_index[0]
      forum.update_column(:plan_id, plan_id)
    end

    change_column_null :forums, :plan_id, false
    remove_column :forums, :plan
  end

  def down
    add_column :forums, :plan, :integer, null: false, default: 0

    MigrationForum.reset_column_information
    key_to_index = PLAN_SEED.transform_values { |attrs| attrs[:key] }.invert

    MigrationForum.find_each do |forum|
      plan = MigrationPlan.find_by(id: forum.plan_id)
      index = key_to_index[plan&.key] || 0
      forum.update_column(:plan, index)
    end

    remove_reference :forums, :plan
  end
end
