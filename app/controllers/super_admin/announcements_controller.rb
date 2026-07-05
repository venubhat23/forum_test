module SuperAdmin
  class AnnouncementsController < BaseController
    before_action :set_announcement, only: [ :edit, :update, :destroy, :publish ]
    before_action :set_form_collections, only: [ :new, :create, :edit, :update ]

    def index
      @announcements = Announcement.order(created_at: :desc)
    end

    def new
      @announcement = Announcement.new(audience: :everyone)
    end

    def create
      @announcement = Announcement.new(announcement_params)
      @announcement.created_by = current_user
      if @announcement.save
        redirect_to super_admin_announcements_path, notice: "Announcement created."
      else
        flash.now[:alert] = @announcement.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @announcement.update(announcement_params)
        redirect_to super_admin_announcements_path, notice: "Announcement updated."
      else
        flash.now[:alert] = @announcement.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @announcement.destroy
      redirect_to super_admin_announcements_path, notice: "Announcement deleted."
    end

    def publish
      @announcement.update!(published_at: Time.current)
      redirect_to super_admin_announcements_path, notice: "Announcement published."
    end

    private

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end

    def set_form_collections
      @forums = Forum.order(:name)
      @plans = Plan.ordered
    end

    def announcement_params
      params.require(:announcement).permit(:title, :body, :audience, :forum_id, :plan_id)
    end
  end
end
