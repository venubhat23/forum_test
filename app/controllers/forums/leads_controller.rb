module Forums
  class LeadsController < BaseController
    before_action :set_lead, only: [ :show, :accept, :release, :advance, :new_thanksgiving, :give_thanksgiving ]

    def index
      authorize! :read, Lead

      if can?(:manage, Lead)
        base = @current_forum.leads
      else
        base = @current_forum.leads.where(
          "created_by_id = :id OR accepted_by_id = :id OR id IN (SELECT lead_id FROM lead_taggings WHERE user_id = :id)",
          id: current_user.id
        )
      end

      @total_leads = base.count
      @requested_leads = base.where(stage: :requested).count
      @converted_leads = base.where(stage: :converted).count
      @thanksgiving_leads = base.where.not(thanksgiving_given_at: nil).count

      @leads = base.includes(:created_by, :tagged_users).order(created_at: :desc)
      @leads = @leads.where(stage: params[:stage]) if params[:stage].present?
      @leads = @leads.page(params[:page])
    end

    def show
      authorize! :read, @lead
    end

    def new
      authorize! :create, Lead
      @lead = Lead.new
      @taggable_members = taggable_members
    end

    def create
      @lead = @current_forum.leads.new(lead_params)
      @lead.created_by = current_user
      authorize! :create, @lead

      tagged_ids = Array(params.dig(:lead, :tagged_user_ids)).reject(&:blank?).map(&:to_i)

      if tagged_ids.empty?
        @lead.errors.add(:base, "Select at least one member to tag")
        @taggable_members = taggable_members
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
        return
      end

      if @lead.save
        tagged_ids.each { |uid| @lead.lead_taggings.create!(user_id: uid) }
        redirect_to forum_lead_path(forum_slug: @current_forum.slug, id: @lead.id), notice: "Lead created and tagged to #{tagged_ids.size} member(s)."
      else
        @taggable_members = taggable_members
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def accept
      authorize! :update, @lead
      raise CanCan::AccessDenied, "You are not tagged on this lead." unless @lead.tagged_users.include?(current_user)

      if @lead.claim!(current_user)
        redirect_to forum_lead_path(forum_slug: @current_forum.slug, id: @lead.id), notice: "Lead accepted — it's yours to work now."
      else
        redirect_to forum_leads_path(forum_slug: @current_forum.slug), alert: "Sorry, someone else already claimed this lead."
      end
    end

    def release
      authorize! :update, @lead
      require_owner!
      @lead.release!
      redirect_to forum_leads_path(forum_slug: @current_forum.slug), notice: "Lead released back to the pool."
    end

    def advance
      authorize! :update, @lead
      require_owner!
      stage = params[:stage].to_s
      if Lead::MANUALLY_ADVANCEABLE_STAGES.include?(stage)
        @lead.update!(stage: stage)
        redirect_to forum_lead_path(forum_slug: @current_forum.slug, id: @lead.id), notice: "Lead moved to #{stage.titleize}."
      else
        redirect_to forum_lead_path(forum_slug: @current_forum.slug, id: @lead.id), alert: "Invalid stage."
      end
    end

    def new_thanksgiving
      authorize! :update, @lead
      require_owner!
    end

    def give_thanksgiving
      authorize! :update, @lead
      require_owner!

      if @lead.update(thanksgiving_params.merge(stage: :converted, thanksgiving_given_at: Time.current))
        redirect_to forum_lead_path(forum_slug: @current_forum.slug, id: @lead.id), notice: "Thanksgiving slip recorded — lead converted!"
      else
        flash.now[:alert] = @lead.errors.full_messages.to_sentence
        render :new_thanksgiving, status: :unprocessable_entity
      end
    end

    private

    def set_lead
      @lead = @current_forum.leads.find(params[:id])
    end

    def require_owner!
      raise CanCan::AccessDenied, "Only the member who accepted this lead can do that." unless @lead.accepted_by_id == current_user.id
    end

    def taggable_members
      @current_forum.users.member.where.not(id: current_user.id).order(:full_name).includes(:chapter)
    end

    def lead_params
      params.require(:lead).permit(:prospect_name, :prospect_phone, :prospect_email, :business_name, :business_category, :requirement, :notes)
    end

    def thanksgiving_params
      params.require(:lead).permit(:thanksgiving_amount, :thanksgiving_notes, :thanksgiving_proof)
    end
  end
end
