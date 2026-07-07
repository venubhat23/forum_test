module SuperAdmin
  class UsersController < BaseController
    before_action :set_user, only: [ :show, :edit, :update, :destroy, :suspend, :unsuspend, :reset_password, :force_logout ]

    def index
      @total_users = User.count
      @active_users = User.where(suspended_at: nil).count
      @suspended_users = User.where.not(suspended_at: nil).count

      @users = User.includes(:forum)
      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.where(forum_id: params[:forum_id]) if params[:forum_id].present?
      @users = @users.where("email ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @users = @users.order(created_at: :desc).page(params[:page])
      @forums = Forum.order(:name)
    end

    def show
    end

    def new
      @user = User.new(role: :super_admin)
      @forums = Forum.order(:name)
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to super_admin_user_path(@user), notice: "#{@user.email} was created."
      else
        @forums = Forum.order(:name)
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @forums = Forum.order(:name)
    end

    def update
      if @user.update(user_update_params)
        redirect_to super_admin_user_path(@user), notice: "#{@user.email} was updated."
      else
        @forums = Forum.order(:name)
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
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :role, :forum_id, :chapter_id, :full_name, :phone)
    end

    def user_update_params
      params.require(:user).permit(:email, :role, :forum_id, :chapter_id, :full_name, :phone)
    end
  end
end
