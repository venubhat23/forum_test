module Forums
  class EventsController < BaseController
    before_action :set_event, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize! :read, Event
      @events = @current_forum.events.order(starts_at: :desc).page(params[:page])
    end

    def show
      authorize! :read, @event
      @registered = @event.event_registrations.exists?(user_id: current_user.id)
    end

    def new
      authorize! :create, Event
      @event = @current_forum.events.new(starts_at: 1.week.from_now)
    end

    def create
      @event = @current_forum.events.new(event_params)
      authorize! :create, @event

      if @event.save
        redirect_to forum_event_path(forum_slug: @current_forum.slug, id: @event.id), notice: "Event created."
      else
        flash.now[:alert] = @event.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @event
    end

    def update
      authorize! :update, @event
      if @event.update(event_params)
        redirect_to forum_event_path(forum_slug: @current_forum.slug, id: @event.id), notice: "Event updated."
      else
        flash.now[:alert] = @event.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @event
      @event.destroy
      redirect_to forum_events_path(forum_slug: @current_forum.slug), notice: "Event deleted."
    end

    private

    def set_event
      @event = @current_forum.events.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:title, :event_type, :starts_at, :venue, :registration_opens_at, :registration_closes_at, gallery: [])
    end
  end
end
