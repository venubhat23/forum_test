module Forums
  class MeetingSchedulesController < BaseController
    before_action :set_chapter
    before_action :set_schedule, only: [ :show, :destroy ]

    def index
      authorize! :read, MeetingSchedule
      @schedules = @chapter.meeting_schedules.order(created_at: :desc)
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
          notice: "Meeting schedule created — #{@schedule.meetings.count} meetings generated."
      else
        @candidates = pickable_people
        flash.now[:alert] = @schedule.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def show
      authorize! :read, @schedule
      @occurrences = @schedule.meetings.order(:scheduled_at)
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
      @chapter.users.where(role: [ :member, :guest, :committee_member, :chapter_admin ]).order(:full_name)
    end

    def meeting_schedule_params
      params.require(:meeting_schedule).permit(:title, :day_of_week, :start_time, :end_time, :start_date, :end_date,
        :venue, :agenda, :notes, attendee_ids: [])
    end
  end
end
