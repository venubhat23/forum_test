class AddCounterCacheColumns < ActiveRecord::Migration[8.0]
  def up
    add_column :forums, :chapters_count, :integer, default: 0, null: false
    add_column :plans, :forums_count, :integer, default: 0, null: false

    execute <<~SQL
      UPDATE forums SET chapters_count = COALESCE(sub.count, 0)
      FROM (SELECT forum_id, COUNT(*) AS count FROM chapters GROUP BY forum_id) sub
      WHERE forums.id = sub.forum_id
    SQL

    execute <<~SQL
      UPDATE plans SET forums_count = COALESCE(sub.count, 0)
      FROM (SELECT plan_id, COUNT(*) AS count FROM forums GROUP BY plan_id) sub
      WHERE plans.id = sub.plan_id
    SQL

    # Duplicate indexes left over from earlier migrations — same columns as
    # the indexes Rails already generated, pure write overhead with no
    # additional query benefit.
    remove_index :role_permissions, name: "idx_role_permissions_permission", if_exists: true
    remove_index :role_permissions, name: "idx_role_permissions_role", if_exists: true
    remove_index :users, name: "idx_users_role_id", if_exists: true
  end

  def down
    remove_column :forums, :chapters_count
    remove_column :plans, :forums_count

    add_index :role_permissions, :permission_id, name: "idx_role_permissions_permission"
    add_index :role_permissions, :role_id, name: "idx_role_permissions_role"
    add_index :users, :role_id, name: "idx_users_role_id"
  end
end
