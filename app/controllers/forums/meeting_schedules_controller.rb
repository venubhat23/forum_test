module Forums
  class MeetingSchedulesController < BaseController
    before_action :set_chapter, except: [ :all ]
    before_action :set_schedule, only: [ :show, :destroy, :add_attendees, :remove_attendee ]

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
      @schedule.attendee_ids = attendee_ids_for_scope
      authorize! :create, @schedule

      if @schedule.save
        redirect_to forum_chapter_meeting_schedule_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @schedule.id),
          notice: "Meeting schedule created — #{helpers.pluralize(@schedule.meetings.count, 'meeting')} scheduled."
      else
        @candidates = pickable_people
        flash.now[:alert] = @schedule.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def show
      authorize! :read, @schedule
      @occurrences = @schedule.meetings.includes(:chapter).order(:scheduled_at)
      @addable_candidates = pickable_people.where.not(id: @schedule.attendee_ids) if can? :update, @schedule
    end

    def destroy
      authorize! :destroy, @schedule
      @schedule.destroy
      redirect_to forum_chapter_meeting_schedules_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "Meeting schedule cancelled."
    end

    # Adds people to an already-created schedule — they're invited to every
    # future occurrence from here on, same as anyone invited at creation.
    def add_attendees
      authorize! :update, @schedule
      new_ids = Array(params[:attendee_ids]).map(&:to_i) - @schedule.attendee_ids
      if new_ids.any?
        @schedule.attendee_ids += new_ids
        @schedule.notify_attendees(User.where(id: new_ids))
      end
      redirect_to forum_chapter_meeting_schedule_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @schedule.id),
        notice: "#{helpers.pluralize(new_ids.size, 'attendee')} added."
    end

    def remove_attendee
      authorize! :update, @schedule
      @schedule.attendee_ids -= [ params[:user_id].to_i ]
      redirect_to forum_chapter_meeting_schedule_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @schedule.id),
        notice: "Attendee removed."
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

    # The bulk "Everyone in this chapter/forum" options are resolved here,
    # server-side, rather than trusted from whatever the client's JS managed
    # to select in the (potentially huge) attendee multi-select — that field
    # is only authoritative for the "specific people" scope.
    def attendee_ids_for_scope
      case params.dig(:meeting_schedule, :attendee_scope)
      when "chapter"
        @chapter.users.where(role: [ :member, :committee_member ]).pluck(:id)
      when "forum"
        @current_forum.users.where(role: [ :member, :committee_member ]).pluck(:id)
      else
        @schedule.attendee_ids
      end
    end

    def meeting_schedule_params
      params.require(:meeting_schedule).permit(:title, :topic, :day_of_week, :start_time, :end_time, :start_date, :end_date,
        :venue, :agenda, :notes, :speaker, :speaker_phone, :fee_amount, :payment_upi_id, :payment_bank_details, :payment_qr, attendee_ids: [])
    end
  end
end
