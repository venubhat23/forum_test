module Forums
  class MeetingSchedulesController < BaseController
    before_action :set_chapter, except: [ :all ]
    before_action :set_schedule, only: [ :show, :destroy ]

    # Forum-wide view across every chapter — this is where the sidebar sends
    # forum/super admins who aren't scoped to a single chapter, instead of
    # dumping them on the generic chapters list.
    def all
      authorize! :read, MeetingSchedule
      @schedules = MeetingSchedule.where(chapter_id: @current_forum.chapters.select(:id))
        .includes(:chapter, :meetings).order(created_at: :desc)
    end

    def index
      authorize! :read, MeetingSchedule
      @schedules = @chapter.meeting_schedules.includes(:meetings).order(created_at: :desc)
    end

    def new
      authorize! :create, MeetingSchedule
      @schedule = @chapter.meeting_schedules.new(start_date: Date.tomorrow, day_of_week: 5)
      @candidates = pickable_people
    end

    def create
      @schedule = @chapter.meeting_schedules.new(meeting_schedule_params)
      @schedule.created_by = current_user
      authorize! :create, @schedule

      if @schedule.save
        redirect_to forum_chapter_meeting_schedule_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @schedule.id),
          notice: "Meeting schedule created — meetings are being generated in the background."
      else
        @candidates = pickable_people
        flash.now[:alert] = @schedule.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def show
      authorize! :read, @schedule
      @occurrences = @schedule.meetings.includes(:chapter).order(:scheduled_at)
    end

    def destroy
      authorize! :destroy, @schedule
      @schedule.destroy
      redirect_to forum_chapter_meeting_schedules_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "Meeting schedule cancelled."
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_schedule
      @schedule = @chapter.meeting_schedules.find(params[:id])
    end

    def pickable_people
      @current_forum.users.includes(:chapter).order(:full_name)
    end

    def meeting_schedule_params
      params.require(:meeting_schedule).permit(:title, :topic, :day_of_week, :start_time, :end_time, :start_date, :end_date,
        :venue, :agenda, :notes, :speaker, :speaker_phone, :fee_amount, attendee_ids: [])
    end
  end
end
