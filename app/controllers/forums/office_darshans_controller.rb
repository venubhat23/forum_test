module Forums
  class OfficeDarshansController < BaseController
    include OfficeDarshansHelper

    before_action :set_darshan, only: [ :show, :edit, :update, :destroy, :accept, :decline, :complete, :thank ]

    def index
      authorize! :read, OfficeDarshan
      base = OfficeDarshan.accessible_by(current_ability).where(forum_id: @current_forum.id)
      @total_darshans = base.count
      @invited_darshans = base.where(status: :invited).count
      @accepted_darshans = base.where(status: :accepted).count
      @completed_darshans = base.where(status: :completed).count

      @darshans = base.includes(:host, :visitor).order(scheduled_at: :desc)
      @darshans = @darshans.where(status: params[:status]) if params[:status].present?
    end

    def show
      authorize! :read, @darshan
    end

    def new
      authorize! :create, OfficeDarshan
      @darshan = @current_forum.office_darshans.new(host: current_user, scheduled_at: 1.day.from_now)
    end

    def create
      @darshan = @current_forum.office_darshans.new(darshan_params)
      is_admin = current_user.forum_admin? || current_user.chapter_admin?
      @darshan.host = current_user unless is_admin
      @darshan.status = :invited unless is_admin
      authorize! :create, @darshan

      if @darshan.save
        notice = is_admin && !@darshan.invited? ? "Office Darshan visit logged." : "Office Darshan invite sent."
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: notice
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

    def accept
      authorize! :update, @darshan
      @darshan.update!(status: :accepted)
      redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Visit accepted."
    end

    def decline
      authorize! :update, @darshan
      @darshan.update!(status: :declined)
      redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Visit declined."
    end

    def complete
      authorize! :complete, @darshan
      @darshan.update!(status: :completed)
      redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Visit marked as successfully visited."
    end

    def thank
      authorize! :thank, @darshan
      unless @darshan.completed?
        return redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), alert: "Mark the visit completed before sending a thank-you."
      end

      link = whatsapp_darshan_thankyou_link(@darshan, current_user)
      if link.blank?
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), alert: "No phone number on file to send a thank-you."
      else
        @darshan.update!(thanked_at: Time.current)
        redirect_to link, allow_other_host: true
      end
    end

    private

    def set_darshan
      @darshan = @current_forum.office_darshans.find(params[:id])
    end

    def darshan_params
      params.require(:office_darshan).permit(:host_id, :visitor_id, :scheduled_at, :status, :notes, photos: [])
    end
  end
end
