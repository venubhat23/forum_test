module SuperAdmin
  class ForumsController < BaseController
    before_action :set_forum, only: [ :show, :suspend, :activate, :update_plan ]

    def index
      @forums = Forum.order(created_at: :desc)
    end

    def show
    end

    def new
      @forum = Forum.new
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
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
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
      @forum.update!(plan: params[:plan])
      redirect_to super_admin_forum_path(@forum), notice: "#{@forum.name} is now on the #{@forum.plan_details[:label]} plan."
    end

    private

    def set_forum
      @forum = Forum.find_by!(slug: params[:id])
    end

    def forum_params
      params.require(:forum).permit(:name, :plan)
    end
  end
end
