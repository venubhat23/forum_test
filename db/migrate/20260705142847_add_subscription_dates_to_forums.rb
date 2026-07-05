class AddSubscriptionDatesToForums < ActiveRecord::Migration[8.0]
  class MigrationForum < ActiveRecord::Base
    self.table_name = "forums"
  end

  class MigrationPlan < ActiveRecord::Base
    self.table_name = "plans"
  end

  TRIAL_STATUS = 0

  def up
    add_column :forums, :started_at, :datetime
    add_column :forums, :trial_ends_at, :datetime
    add_column :forums, :renews_on, :date

    MigrationForum.reset_column_information
    MigrationForum.find_each do |forum|
      plan = MigrationPlan.find_by(id: forum.plan_id)
      started = forum.created_at
      trial_days = plan&.trial_days.to_i
      annual = plan&.billing_cycle.to_i == 1

      forum.update_columns(
        started_at: started,
        trial_ends_at: (forum.read_attribute(:status) == TRIAL_STATUS ? started + trial_days.days : nil),
        renews_on: started.to_date + (annual ? 1.year : 1.month)
      )
    end
  end

  def down
    remove_column :forums, :started_at
    remove_column :forums, :trial_ends_at
    remove_column :forums, :renews_on
  end
end
