module SuperAdmin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_super_admin!

    private

    def authorize_super_admin!
      authorize! :access, :super_admin_area, message: "You don't have access to that area."
    end
  end
end
