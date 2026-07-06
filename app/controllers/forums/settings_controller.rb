module Forums
  class SettingsController < BaseController
    before_action :require_forum_admin!

    def edit
      @setting = ForumSetting.for(@current_forum)
    end

    def update
      @setting = ForumSetting.for(@current_forum)
      if @setting.update(setting_params)
        redirect_to edit_forum_settings_path(forum_slug: @current_forum.slug), notice: "Settings updated."
      else
        flash.now[:alert] = @setting.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def require_forum_admin!
      redirect_to forum_dashboard_path(forum_slug: @current_forum.slug), alert: "Only the Forum Admin can access settings." unless current_user.forum_admin? || current_user.super_admin?
    end

    def setting_params
      params.require(:forum_setting).permit(:theme_color, :invoice_prefix, :attendance_rules, :meeting_rules, :membership_rules, :logo)
    end
  end
end
