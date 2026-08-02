class ImpersonationsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    impersonator_id = session[:impersonator_id]
    impersonator = impersonator_id && User.find_by(id: impersonator_id, role: [ :super_admin, :forum_admin, :chapter_admin ])

    if impersonator
      session.delete(:impersonator_id)
      sign_in(:user, impersonator, event: :authentication)
      if impersonator.super_admin?
        redirect_to super_admin_dashboard_path, notice: "You are back in your Super Admin account."
      else
        redirect_to forum_dashboard_path(forum_slug: impersonator.forum.slug), notice: "You are back in your account."
      end
    else
      redirect_to root_path, alert: "No impersonation session found."
    end
  end
end
