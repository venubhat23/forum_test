module SuperAdmin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :edit, :update, :destroy, :suspend, :unsuspend, :reset_password, :force_logout ]

    def index
      @total_users = User.where(role: User::INTERNAL_ROLES).count
      @active_users = User.where(role: User::INTERNAL_ROLES, suspended_at: nil).count
      @suspended_users = User.where(role: User::INTERNAL_ROLES).where.not(suspended_at: nil).count

      @users = User.where(role: User::INTERNAL_ROLES)
      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.where("email ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @users = @users.order(created_at: :desc).page(params[:page])
    end

    def show
    end

    def new
      @user = User.new(role: :super_admin)
    end

    def create
      @user = User.new(user_params)
      unless User::INTERNAL_ROLES.include?(@user.role)
        @user.errors.add(:role, "must be an internal role")
        flash.now[:alert] = "Invalid role selected."
        render :new, status: :unprocessable_entity
        return
      end

      if @user.save
        redirect_to super_admin_user_path(@user), notice: "#{@user.email} was created."
      else
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      unless User::INTERNAL_ROLES.include?(user_update_params[:role] || @user.role)
        flash.now[:alert] = "Invalid role selected."
        render :edit, status: :unprocessable_entity
        return
      end

      if @user.update(user_update_params)
        redirect_to super_admin_user_path(@user), notice: "#{@user.email} was updated."
      else
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user
        redirect_to super_admin_users_path, alert: "You can't delete your own account."
        return
      end

      @user.destroy
      redirect_to super_admin_users_path, notice: "#{@user.email} was deleted."
    end

    def suspend
      @user.suspend!
      redirect_to super_admin_user_path(@user), notice: "#{@user.email} has been suspended."
    end

    def unsuspend
      @user.unsuspend!
      redirect_to super_admin_user_path(@user), notice: "#{@user.email} has been reactivated."
    end

    def reset_password
      new_password = SecureRandom.alphanumeric(12)
      @user.password = new_password
      @user.password_confirmation = new_password
      @user.save!
      @user.force_logout!
      redirect_to super_admin_user_path(@user), notice: "New password for #{@user.email}: #{new_password} (copy this now, it won't be shown again)."
    end

    def force_logout
      @user.force_logout!
      redirect_to super_admin_user_path(@user), notice: "#{@user.email} has been signed out of all active sessions."
    end

    private

    def set_user
      @user = User.where(role: User::INTERNAL_ROLES).find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :role, :full_name, :phone)
    end

    def user_update_params
      params.require(:user).permit(:email, :role, :full_name, :phone)
    end
  end
end
