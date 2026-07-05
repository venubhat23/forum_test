class ImpersonationsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    impersonator_id = session[:impersonator_id]
    super_admin = impersonator_id && User.find_by(id: impersonator_id, role: :super_admin)

    if super_admin
      session.delete(:impersonator_id)
      sign_in(:user, super_admin, event: :authentication)
      redirect_to super_admin_dashboard_path, notice: "You are back in your Super Admin account."
    else
      redirect_to root_path, alert: "No impersonation session found."
    end
  end
end
