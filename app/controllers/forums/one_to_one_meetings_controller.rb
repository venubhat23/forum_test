module Forums
  class OneToOneMeetingsController < BaseController
    before_action :set_meeting, only: [ :show, :edit, :update, :destroy, :accept, :reject, :complete ]

    def index
      authorize! :read, OneToOneMeeting
      base = OneToOneMeeting.accessible_by(current_ability).where(forum_id: @current_forum.id)
      @total_meetings = base.count
      @requested_meetings = base.where(status: :requested).count
      @accepted_meetings = base.where(status: :accepted).count
      @completed_meetings = base.where(status: :completed).count

      @meetings = base.includes(:requester, :requested_with).order(scheduled_at: :desc)
      @meetings = @meetings.where(status: params[:status]) if params[:status].present?
    end

    def show
      authorize! :read, @meeting
    end

    def new
      authorize! :create, OneToOneMeeting
      @meeting = @current_forum.one_to_one_meetings.new(requester: current_user, scheduled_at: 1.day.from_now)
    end

    def create
      @meeting = @current_forum.one_to_one_meetings.new(meeting_params)
      @meeting.requester = current_user unless current_user.forum_admin? || current_user.chapter_admin?
      authorize! :create, @meeting

      if @meeting.save
        redirect_to forum_one_to_one_meeting_path(forum_slug: @current_forum.slug, id: @meeting.id), notice: "One-to-One meeting requested."
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
        redirect_to forum_one_to_one_meeting_path(forum_slug: @current_forum.slug, id: @meeting.id), notice: "Meeting updated."
      else
        flash.now[:alert] = @meeting.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @meeting
      @meeting.destroy
      redirect_to forum_one_to_one_meetings_path(forum_slug: @current_forum.slug), notice: "Meeting cancelled."
    end

    def accept
      authorize! :update, @meeting
      @meeting.update!(status: :accepted)
      redirect_to forum_one_to_one_meeting_path(forum_slug: @current_forum.slug, id: @meeting.id), notice: "Meeting accepted."
    end

    def reject
      authorize! :update, @meeting
      @meeting.update!(status: :rejected)
      redirect_to forum_one_to_one_meeting_path(forum_slug: @current_forum.slug, id: @meeting.id), notice: "Meeting rejected."
    end

    def complete
      authorize! :update, @meeting
      @meeting.update!(status: :completed)
      redirect_to forum_one_to_one_meeting_path(forum_slug: @current_forum.slug, id: @meeting.id), notice: "Meeting marked completed."
    end

    private

    def set_meeting
      @meeting = @current_forum.one_to_one_meetings.find(params[:id])
    end

    def meeting_params
      params.require(:one_to_one_meeting).permit(:requester_id, :requested_with_id, :scheduled_at, :notes, :follow_up_on, :fee_amount)
    end
  end
end
