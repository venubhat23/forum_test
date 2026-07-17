module SuperAdmin
  class PlansController < BaseController
    before_action :set_plan, only: [ :edit, :update, :archive, :activate ]

    def index
      @total_plans = Plan.count
      @active_plans = Plan.active.count
      @archived_plans = Plan.archived.count

      @plans = Plan.includes(:forums).ordered
      @plans = @plans.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @plans = @plans.where(status: params[:status]) if params[:status].present?
    end

    def new
      @plan = Plan.new(billing_cycle: :monthly, trial_days: 14)
    end

    def create
      @plan = Plan.new(plan_params)

      if @plan.save
        redirect_to super_admin_plans_path, notice: "#{@plan.name} plan was created."
      else
        flash.now[:alert] = @plan.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @plan.update(plan_params)
        redirect_to super_admin_plans_path, notice: "#{@plan.name} plan was updated."
      else
        flash.now[:alert] = @plan.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def archive
      @plan.update!(status: :archived)
      redirect_to super_admin_plans_path, notice: "#{@plan.name} plan was archived."
    end

    def activate
      @plan.update!(status: :active)
      redirect_to super_admin_plans_path, notice: "#{@plan.name} plan was activated."
    end

    private

    def set_plan
      @plan = Plan.find(params[:id])
    end

    def plan_params
      features = params.dig(:plan, :features).to_s.split("\n").map(&:strip).reject(&:blank?)
      params.require(:plan).permit(:key, :name, :price, :billing_cycle, :member_limit, :chapter_limit, :trial_days, :position)
        .merge(features: features)
    end
  end
end
