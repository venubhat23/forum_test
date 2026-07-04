module Forums
  class DashboardController < BaseController
    def show
      @chapters_count = @current_forum.chapters.count
      @members_count = @current_forum.users.member.count
      @guests_count = @current_forum.users.guest.count
      @recent_chapters = @current_forum.chapters.order(created_at: :desc).limit(5)
    end
  end
end
