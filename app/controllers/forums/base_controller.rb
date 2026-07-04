module Forums
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :set_current_forum
    before_action :require_forum_access!

    private

    def set_current_forum
      @current_forum = Forum.find_by!(slug: params[:forum_slug])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Forum not found."
    end

    def require_forum_access!
      return if current_user.super_admin?
      return if current_user.forum_id == @current_forum.id

      redirect_to root_path, alert: "You don't have access to that forum."
    end
  end
end
