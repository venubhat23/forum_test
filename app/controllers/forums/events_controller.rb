module Forums
  class EventsController < BaseController
    before_action :set_event, only: [ :show, :edit, :update, :destroy, :remind, :attendance, :record_attendance ]

    def index
      authorize! :read, Event
      @total_events = @current_forum.events.count
      @upcoming_events = @current_forum.events.where("starts_at >= ?", Time.current).count
      @past_events = @current_forum.events.where("starts_at < ?", Time.current).count

      @events = @current_forum.events.includes(:event_registrations).order(starts_at: :desc)
      @events = @events.where("title ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @events = @events.where(event_type: params[:event_type]) if params[:event_type].present?
      @events = @events.page(params[:page])
    end

    def show
      authorize! :read, @event
      @registered = @event.event_registrations.exists?(user_id: current_user.id)
      if can?(:update, @event)
        @addable_members = @current_forum.users.where.not(id: @event.registrants.select(:id)).order(:full_name)
      end
    end

    def new
      authorize! :create, Event
      @event = @current_forum.events.new(starts_at: 1.week.from_now)
    end

    def create
      @event = @current_forum.events.new(event_params)
      authorize! :create, @event

      if @event.save
        @current_forum.users.where(id: Array(params[:member_ids]).reject(&:blank?)).find_each do |user|
          @event.event_registrations.find_or_create_by(user: user)
        end
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

    def remind
      authorize! :update, @event

      if @event.fee_amount.present?
        paid_user_ids = @event.fee_payments.paid.pluck(:user_id)
        recipients = @event.registrants.where.not(id: paid_user_ids)
        amount_text = " Fee: #{helpers.number_to_currency(@event.fee_amount)} — see the event page for payment details."
      else
        recipients = @event.registrants
        amount_text = ""
      end

      message = "Reminder: #{@event.title} is coming up on #{@event.starts_at.strftime('%d %b %Y at %I:%M %p')}.#{amount_text}"
      sent_count = recipients.count
      recipients.find_each { |user| user.notifications.create!(body: message) }

      redirect_to forum_event_path(forum_slug: @current_forum.slug, id: @event.id), notice: "Reminder sent to #{sent_count} registrant(s)."
    end

    def attendance
      authorize! :update, @event
      @registrations = @event.event_registrations.joins(:user).includes(:user).order("users.full_name")
    end

    def record_attendance
      authorize! :update, @event
      present_ids = Array(params[:present_user_ids]).map(&:to_i)

      @event.event_registrations.find_each do |registration|
        present = present_ids.include?(registration.user_id)
        registration.update!(attended: present, attended_at: present ? Time.current : nil)
      end

      redirect_to forum_event_path(forum_slug: @current_forum.slug, id: @event.id),
        notice: "Attendance recorded for #{@event.event_registrations.count} registrant(s)."
    end

    private

    def set_event
      @event = @current_forum.events.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:title, :event_type, :starts_at, :venue, :speaker, :speaker_phone, :registration_opens_at, :registration_closes_at,
        :fee_amount, :payment_upi_id, :payment_bank_details, :payment_qr, gallery: [])
    end
  end
end
