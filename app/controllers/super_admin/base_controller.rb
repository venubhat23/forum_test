module SuperAdmin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_super_admin!

    private

    def require_super_admin!
      return if current_user.super_admin?

      redirect_to root_path, alert: "You don't have access to that area."
    end
  end
end
