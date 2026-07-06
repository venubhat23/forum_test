module Forums
  class MeetingsController < BaseController
    before_action :set_chapter
    before_action :set_meeting, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize! :read, Meeting
      @meetings = @chapter.meetings.order(scheduled_at: :desc).page(params[:page])
    end

    def show
      authorize! :read, @meeting
    end

    def new
      authorize! :create, Meeting
      @meeting = @chapter.meetings.new(scheduled_at: Time.current)
    end

    def create
      @meeting = @chapter.meetings.new(meeting_params)
      authorize! :create, @meeting

      if @meeting.save
        redirect_to forum_chapter_meeting_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @meeting.id), notice: "Meeting scheduled."
      else
        flash.now[:alert] = @meeting.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @meeting
    end

    def update
      authorize! :update, @meeting
      if @meeting.update(meeting_params)
        redirect_to forum_chapter_meeting_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @meeting.id), notice: "Meeting updated."
      else
        flash.now[:alert] = @meeting.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @meeting
      @meeting.destroy
      redirect_to forum_chapter_meetings_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "Meeting deleted."
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_meeting
      @meeting = @chapter.meetings.find(params[:id])
    end

    def meeting_params
      params.require(:meeting).permit(:meeting_type, :scheduled_at, :venue, :speaker, :agenda, :minutes, documents: [])
    end
  end
end
