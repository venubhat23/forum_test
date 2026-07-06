module SuperAdmin
  class ForumsController < BaseController
    before_action :set_forum, only: [ :show, :edit, :update, :destroy, :suspend, :activate, :update_plan,
                                       :impersonate, :reset_admin_password, :force_logout_admin ]

    def index
      @total_forums = Forum.count
      @active_forums = Forum.active.count
      @trial_forums = Forum.trial.count
      @suspended_forums = Forum.suspended.count

      @forums = Forum.all
      @forums = @forums.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @forums = @forums.where(status: params[:status]) if params[:status].present?
      @forums = @forums.order(created_at: :desc).page(params[:page])
    end

    def show
    end

    def new
      @forum = Forum.new
      @plans = Plan.ordered.active
    end

    def create
      @forum = Forum.new(forum_params)
      admin_email = params.dig(:admin, :email)
      admin_password = params.dig(:admin, :password)

      ActiveRecord::Base.transaction do
        @forum.save!
        @admin = User.new(
          email: admin_email,
          password: admin_password,
          password_confirmation: admin_password,
          role: :forum_admin,
          forum: @forum
        )
        @admin.save!
      end

      redirect_to super_admin_forum_path(@forum), notice: "#{@forum.name} was created with admin login #{admin_email}."
    rescue ActiveRecord::RecordInvalid => e
      @admin ||= User.new(email: admin_email, role: :forum_admin)
      @admin.valid?
      @plans = Plan.ordered.active
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end

    def edit
    end

    def update
      if @forum.update(forum_update_params)
        redirect_to super_admin_forum_path(@forum), notice: "#{@forum.name} was updated."
      else
        flash.now[:alert] = @forum.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @forum.update!(status: :archived)
      redirect_to super_admin_forums_path, notice: "#{@forum.name} has been archived."
    end

    def suspend
      @forum.update!(status: :suspended)
      redirect_to super_admin_forum_path(@forum), notice: "#{@forum.name} has been suspended."
    end

    def activate
      @forum.update!(status: :active)
      redirect_to super_admin_forum_path(@forum), notice: "#{@forum.name} has been activated."
    end

    def update_plan
      plan = Plan.find(params[:plan_id])
      @forum.update!(plan: plan)
      redirect_to super_admin_forum_path(@forum), notice: "#{@forum.name} is now on the #{plan.name} plan."
    end

    def impersonate
      admin = @forum.admin
      if admin.nil?
        redirect_to super_admin_forum_path(@forum), alert: "#{@forum.name} has no admin to impersonate."
        return
      end

      session[:impersonator_id] = current_user.id
      sign_in(:user, admin, event: :authentication)
      redirect_to forum_dashboard_path(forum_slug: @forum.slug), notice: "You are now viewing as #{admin.email}."
    end

    def reset_admin_password
      admin = @forum.admin
      if admin.nil?
        redirect_to super_admin_forum_path(@forum), alert: "#{@forum.name} has no admin login to reset."
        return
      end

      new_password = SecureRandom.alphanumeric(12)
      admin.password = new_password
      admin.password_confirmation = new_password
      admin.save!
      admin.force_logout!
      redirect_to super_admin_forum_path(@forum), notice: "New password for #{admin.email}: #{new_password} (copy this now, it won't be shown again)."
    end

    def force_logout_admin
      admin = @forum.admin
      if admin.nil?
        redirect_to super_admin_forum_path(@forum), alert: "#{@forum.name} has no admin login."
        return
      end

      admin.force_logout!
      redirect_to super_admin_forum_path(@forum), notice: "#{admin.email} has been signed out of all active sessions."
    end

    private

    def set_forum
      @forum = Forum.find_by!(slug: params[:id])
    end

    def forum_params
      params.require(:forum).permit(:name, :plan_id)
    end

    def forum_update_params
      params.require(:forum).permit(:name)
    end
  end
end
