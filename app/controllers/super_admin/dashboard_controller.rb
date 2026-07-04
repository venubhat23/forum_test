module SuperAdmin
  class DashboardController < BaseController
    def show
      @total_forums = Forum.count
      @active_forums = Forum.active.count
      @trial_forums = Forum.trial.count
      @suspended_forums = Forum.suspended.count
      @total_chapters = Chapter.count
      @total_forum_admins = User.forum_admin.count
      @recent_forums = Forum.order(created_at: :desc).limit(5)
    end
  end
end
