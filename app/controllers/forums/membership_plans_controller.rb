module Forums
  class MembershipPlansController < BaseController
    before_action :set_plan, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize! :read, MembershipPlan
      @total_plans = @current_forum.membership_plans.count

      @plans = @current_forum.membership_plans.order(:name)
      @plans = @plans.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    end

    def show
      authorize! :read, @plan
    end

    def new
      authorize! :create, MembershipPlan
      @plan = @current_forum.membership_plans.new
    end

    def create
      @plan = @current_forum.membership_plans.new(plan_params)
      authorize! :create, @plan

      if @plan.save
        redirect_to forum_membership_plans_path(forum_slug: @current_forum.slug), notice: "#{@plan.name} plan created."
      else
        flash.now[:alert] = @plan.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @plan
    end

    def update
      authorize! :update, @plan
      if @plan.update(plan_params)
        redirect_to forum_membership_plans_path(forum_slug: @current_forum.slug), notice: "#{@plan.name} plan updated."
      else
        flash.now[:alert] = @plan.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @plan
      @plan.destroy
      redirect_to forum_membership_plans_path(forum_slug: @current_forum.slug), notice: "#{@plan.name} plan deleted."
    end

    private

    def set_plan
      @plan = @current_forum.membership_plans.find(params[:id])
    end

    def plan_params
      params.require(:membership_plan).permit(:name, :cycle, :price, :renewal_rules)
    end
  end
end
