class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :enforce_account_active!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message.presence || "You don't have access to that area."
  end

  def after_sign_in_path_for(resource)
    session[:seen_announcement_ids] = []

    if resource.super_admin?
      super_admin_dashboard_path
    elsif resource.forum
      forum_dashboard_path(forum_slug: resource.forum.slug)
    else
      awaiting_forum_path
    end
  end

  private

  def enforce_account_active!
    return unless user_signed_in?
    return unless current_user.suspended?

    sign_out(current_user)
    redirect_to new_user_session_path, alert: "Your account has been suspended."
  end
end
