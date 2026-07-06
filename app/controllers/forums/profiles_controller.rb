module Forums
  class ProfilesController < BaseController
    def edit
      @user = current_user
    end

    def update
      @user = current_user
      if profile_params[:password].present?
        if @user.update_with_password(profile_params)
          redirect_to edit_forum_profile_path(forum_slug: @current_forum.slug), notice: "Profile and password updated."
        else
          flash.now[:alert] = @user.errors.full_messages.to_sentence
          render :edit, status: :unprocessable_entity
        end
      else
        if @user.update(profile_params.except(:password, :password_confirmation, :current_password))
          redirect_to edit_forum_profile_path(forum_slug: @current_forum.slug), notice: "Profile updated."
        else
          flash.now[:alert] = @user.errors.full_messages.to_sentence
          render :edit, status: :unprocessable_entity
        end
      end
    end

    def force_logout_others
      current_user.force_logout!
      # Re-authenticate this session with the new token (event: :authentication
      # bypasses the mismatch check in the Warden hook) so only OTHER sessions
      # still holding the old token get invalidated on their next request.
      sign_in(:user, current_user, event: :authentication, force: true)
      redirect_to edit_forum_profile_path(forum_slug: @current_forum.slug), notice: "All other sessions have been signed out."
    end

    private

    def profile_params
      params.require(:user).permit(:full_name, :phone, :email, :password, :password_confirmation, :current_password)
    end
  end
end
