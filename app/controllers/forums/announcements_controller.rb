module Forums
  class AnnouncementsController < BaseController
    before_action :set_announcement, only: [ :destroy ]

    def index
      authorize! :read, Announcement
      @announcements = Announcement.where(forum: @current_forum).or(Announcement.where(audience: :everyone)).order(created_at: :desc)
    end

    def new
      authorize! :create, Announcement
      @announcement = Announcement.new
    end

    def create
      @announcement = Announcement.new(announcement_params)
      @announcement.audience = :specific_forum
      @announcement.forum = @current_forum
      @announcement.created_by = current_user
      @announcement.published_at ||= Time.current
      authorize! :create, Announcement

      if @announcement.save
        redirect_to forum_announcements_path(forum_slug: @current_forum.slug), notice: "Announcement posted to #{@current_forum.name}."
      else
        flash.now[:alert] = @announcement.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, Announcement
      @announcement.destroy
      redirect_to forum_announcements_path(forum_slug: @current_forum.slug), notice: "Announcement deleted."
    end

    private

    def set_announcement
      @announcement = Announcement.find_by!(id: params[:id], forum_id: @current_forum.id)
    end

    def announcement_params
      params.require(:announcement).permit(:title, :body)
    end
  end
end
