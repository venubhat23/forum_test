class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def after_sign_in_path_for(resource)
    if resource.super_admin?
      super_admin_dashboard_path
    elsif resource.forum
      forum_dashboard_path(forum_slug: resource.forum.slug)
    else
      root_path
    end
  end
end
