module Forums
  class GuestsController < BaseController
    before_action :set_chapter

    def index
      @guests = @chapter.guests.order(:full_name).page(params[:page])
    end

    def new
      @guest = @chapter.guests.new
    end

    def create
      @guest = @chapter.guests.new(guest_params)
      @guest.forum = @current_forum
      @guest.role = :guest

      if @guest.save
        redirect_to forum_chapter_guests_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "#{@guest.display_name} was added as a guest."
      else
        flash.now[:alert] = @guest.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def guest_params
      params.require(:guest).permit(:full_name, :email, :phone, :nature_of_business,
        :business_category, :speciality, :invited_by_id)
    end
  end
end
