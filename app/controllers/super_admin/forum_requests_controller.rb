module SuperAdmin
  class ForumRequestsController < BaseController
    before_action :set_forum_request, only: [ :show, :approve, :reject ]

    def index
      @forum_requests = ForumRequest.order(created_at: :desc)
    end

    def show
      @plans = Plan.ordered.active
    end

    def approve
      plan = Plan.find_by(id: params[:plan_id]) || Plan.ordered.active.first
      admin_email = params.dig(:admin, :email).presence || @forum_request.email
      admin_password = params.dig(:admin, :password)

      ActiveRecord::Base.transaction do
        forum = Forum.create!(name: @forum_request.company_name, plan: plan)
        User.create!(
          email: admin_email,
          password: admin_password,
          password_confirmation: admin_password,
          role: :forum_admin,
          forum: forum
        )
        @forum_request.update!(status: :approved, forum: forum, reviewed_by: current_user)
      end

      redirect_to super_admin_forum_request_path(@forum_request), notice: "#{@forum_request.company_name} approved and forum created with admin login #{admin_email}."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to super_admin_forum_request_path(@forum_request), alert: e.record.errors.full_messages.to_sentence
    end

    def reject
      @forum_request.update!(status: :rejected, review_note: params[:review_note], reviewed_by: current_user)
      redirect_to super_admin_forum_requests_path, notice: "Request from #{@forum_request.company_name} rejected."
    end

    private

    def set_forum_request
      @forum_request = ForumRequest.find(params[:id])
    end
  end
end
