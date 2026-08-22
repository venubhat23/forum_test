class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    # current_user.notifications.unread — checked on every forums-namespace
    # page load via the notification bell.
    add_index :notifications, [ :user_id, :read_at ], algorithm: :concurrently, if_not_exists: true

    # Forum#members / Chapter#members-style role-scoped lookups, hit on
    # nearly every forums/* page via current_forum/current_chapter.
    add_index :users, [ :forum_id, :role ], algorithm: :concurrently, if_not_exists: true
    add_index :users, [ :chapter_id, :role ], algorithm: :concurrently, if_not_exists: true

    # Forum#collected_amount / Chapter#collected_amount:
    # FeePayment.joins(:user).where(status: :paid).sum(:amount)
    add_index :fee_payments, [ :user_id, :status ], algorithm: :concurrently, if_not_exists: true

    # Lead pipeline board: filtered/grouped by stage within a forum.
    add_index :leads, [ :forum_id, :stage ], algorithm: :concurrently, if_not_exists: true

    # Support ticket queues filtered by forum + status.
    add_index :support_tickets, [ :forum_id, :status ], algorithm: :concurrently, if_not_exists: true

    # Meeting#attendance_percentage / .attendance_percentages: filters
    # present=true per meeting_id set.
    add_index :attendances, [ :meeting_id, :present ], algorithm: :concurrently, if_not_exists: true

    # Event#attendance_percentage: filters attended=true per event_id.
    add_index :event_registrations, [ :event_id, :attended ], algorithm: :concurrently, if_not_exists: true
  end
end
