module Forums
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_current_forum
    before_action :authorize_forum_access!
    before_action :set_active_announcements

    private

    def set_active_announcements
      @active_announcements = Announcement.for_forum(@current_forum)
    end

    def set_current_forum
      @current_forum = Forum.find_by!(slug: params[:forum_slug])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Forum not found."
    end

    def authorize_forum_access!
      authorize! :access, @current_forum, message: "You don't have access to that forum."
    end
  end
end
