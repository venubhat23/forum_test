module Forums
  class NotificationsController < BaseController
    def index
      @notifications = current_user.notifications.order(created_at: :desc).limit(50)
    end

    def mark_read
      notification = current_user.notifications.find(params[:id])
      notification.mark_read!
      redirect_back fallback_location: forum_notifications_path(forum_slug: @current_forum.slug)
    end

    def mark_all_read
      current_user.notifications.unread.update_all(read_at: Time.current)
      redirect_back fallback_location: forum_notifications_path(forum_slug: @current_forum.slug)
    end
  end
end
