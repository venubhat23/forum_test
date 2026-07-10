module Forums
  class GatewayController < ApplicationController
    def show
      @forum = Forum.find_by!(slug: params[:forum_slug])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: "Forum not found."
    else
      if user_signed_in?
        redirect_to after_sign_in_path_for(current_user)
      else
        @setting = @forum.forum_setting
      end
    end
  end
end
