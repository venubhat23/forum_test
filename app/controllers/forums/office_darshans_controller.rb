module Forums
  class OfficeDarshansController < BaseController
    before_action :set_darshan, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize! :read, OfficeDarshan
      @darshans = OfficeDarshan.accessible_by(current_ability).where(forum_id: @current_forum.id).order(visit_date: :desc)
    end

    def show
      authorize! :read, @darshan
    end

    def new
      authorize! :create, OfficeDarshan
      @darshan = @current_forum.office_darshans.new(visit_date: Date.current)
    end

    def create
      @darshan = @current_forum.office_darshans.new(darshan_params)
      authorize! :create, @darshan

      if @darshan.save
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Office Darshan visit scheduled."
      else
        flash.now[:alert] = @darshan.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @darshan
    end

    def update
      authorize! :update, @darshan
      if @darshan.update(darshan_params)
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Visit updated."
      else
        flash.now[:alert] = @darshan.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @darshan
      @darshan.destroy
      redirect_to forum_office_darshans_path(forum_slug: @current_forum.slug), notice: "Visit deleted."
    end

    private

    def set_darshan
      @darshan = @current_forum.office_darshans.find(params[:id])
    end

    def darshan_params
      params.require(:office_darshan).permit(:member_id, :visit_date, :status, :notes, photos: [])
    end
  end
end
