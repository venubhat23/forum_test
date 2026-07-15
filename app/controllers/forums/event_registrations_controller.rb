module Forums
  class EventRegistrationsController < BaseController
    before_action :set_event

    def index
      authorize! :read, EventRegistration
      @registrations = @event.event_registrations.includes(:user).order(:created_at)
    end

    def create
      user_ids = Array(params[:user_id]).reject(&:blank?)

      if user_ids.any?
        users = @current_forum.users.where(id: user_ids)
        added = users.select do |user|
          registration = @event.event_registrations.new(user: user)
          authorize! :create, registration
          registration.save
        end
        notice = added.any? ? "#{added.size} member(s) added to #{@event.title}." : nil
        alert = added.size < users.size ? "Some members were already registered." : nil
        redirect_to forum_event_path(forum_slug: @current_forum.slug, id: @event.id), notice: notice, alert: alert
      else
        @registration = @event.event_registrations.new(user: current_user)
        authorize! :create, @registration

        if @registration.save
          redirect_to forum_event_path(forum_slug: @current_forum.slug, id: @event.id), notice: "You're registered for #{@event.title}."
        else
          redirect_to forum_event_path(forum_slug: @current_forum.slug, id: @event.id), alert: @registration.errors.full_messages.to_sentence
        end
      end
    end

    def destroy
      @registration = @event.event_registrations.find(params[:id])
      authorize! :destroy, @registration
      @registration.destroy
      redirect_to forum_event_path(forum_slug: @current_forum.slug, id: @event.id), notice: "Registration cancelled."
    end

    private

    def set_event
      @event = @current_forum.events.find(params[:event_id])
    end
  end
end
