class HomeController < ApplicationController
  before_action :authenticate_user!

  # Sends a signed-in user to their role's home area.
  def dashboard
    redirect_to after_sign_in_path_for(current_user)
  end
end
