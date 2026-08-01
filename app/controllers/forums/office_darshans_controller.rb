module Forums
  class OfficeDarshansController < BaseController
    include OfficeDarshansHelper

    before_action :set_darshan, only: [ :show, :edit, :update, :destroy, :accept, :decline, :complete, :thank, :schedule, :remind ]

    def index
      authorize! :read, OfficeDarshan
      base = OfficeDarshan.accessible_by(current_ability).where(forum_id: @current_forum.id)
      @total_darshans = base.count
      @invited_darshans = base.where(status: :invited).count
      @accepted_darshans = base.where(status: :accepted).count
      @completed_darshans = base.where(status: :completed).count

      @darshans = base.includes(:host, :visitor, :chapter, :attendances).order(scheduled_at: :desc)
      @darshans = @darshans.where(status: params[:status]) if params[:status].present?
    end

    def show
      authorize! :read, @darshan
      @attendances = @darshan.attendances.includes(:user).order(:rsvp_status) if @darshan.attendances.any?
      @my_attendance = @darshan.attendances.find_by(user: current_user)
    end

    def new
      authorize! :create, OfficeDarshan
      @darshan = @current_forum.office_darshans.new(host: current_user, scheduled_at: 1.day.from_now,
        scope: :member, visitor_id: params[:visitor_id])
    end

    def create
      @darshan = @current_forum.office_darshans.new(darshan_params)
      is_admin = current_user.forum_admin? || current_user.chapter_admin?
      @darshan.host = current_user unless is_admin
      @darshan.status = :invited unless is_admin
      @darshan.chapter ||= current_user.chapter if @darshan.scope_chapter?
      authorize! :create, @darshan

      if @darshan.save
        notice = if is_admin && !@darshan.invited?
          "Office Darshan visit logged."
        elsif @darshan.scope_member?
          "Office Darshan invite sent."
        else
          "Office Darshan invite sent to #{@darshan.attendances.count} member(s)."
        end
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: notice
      else
        flash.now[:alert] = @darshan.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @darshan
    end

    def update
      authorize! :update, @darshan
      if @darshan.update(darshan_params)
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Visit updated."
      else
        flash.now[:alert] = @darshan.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @darshan
      @darshan.destroy
      redirect_to forum_office_darshans_path(forum_slug: @current_forum.slug), notice: "Visit deleted."
    end

    def accept
      authorize! :update, @darshan
      @darshan.update!(status: :accepted)
      redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Visit accepted."
    end

    def decline
      authorize! :update, @darshan
      @darshan.update!(status: :declined)
      redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Visit declined."
    end

    def complete
      authorize! :complete, @darshan
      @darshan.update!(status: :completed)
      @darshan.attendances.coming.find_each { |a| a.update!(attended: true, attended_at: Time.current) }
      redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Visit marked as successfully visited."
    end

    def thank
      authorize! :thank, @darshan
      unless @darshan.completed?
        return redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), alert: "Mark the visit completed before sending a thank-you."
      end
      if @darshan.attendances.any?
        return redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), alert: "This visit collects attendee reviews instead of a WhatsApp thank-you."
      end

      link = whatsapp_darshan_thankyou_link(@darshan, current_user)
      if link.blank?
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), alert: "No phone number on file to send a thank-you."
      else
        @darshan.update!(thanked_at: Time.current)
        redirect_to link, allow_other_host: true
      end
    end

    def schedule
      authorize! :schedule, @darshan
      if @darshan.update(schedule_params.merge(status: :scheduled))
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Visit scheduled — reminders are now active."
      else
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), alert: @darshan.errors.full_messages.to_sentence
      end
    end

    def remind
      authorize! :remind, @darshan
      pending = @darshan.attendances.invited
      pending.find_each { |a| a.user.notifications.create!(body: "Reminder: RSVP for #{@darshan.host.display_name}'s office darshan visit on #{@darshan.scheduled_at.strftime('%d %b %Y %H:%M')}.") }
      @darshan.attendances.coming.find_each { |a| a.user.notifications.create!(body: "Reminder: office darshan visit on #{@darshan.scheduled_at.strftime('%d %b %Y %H:%M')}#{" at #{@darshan.venue}" if @darshan.venue.present?}.") }
      @darshan.attendances.update_all(reminded_at: Time.current)
      redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Reminder sent to #{@darshan.attendances.count} attendee(s)."
    end

    private

    def set_darshan
      @darshan = @current_forum.office_darshans.find(params[:id])
    end

    def darshan_params
      params.require(:office_darshan).permit(:host_id, :visitor_id, :scope, :chapter_id, :venue, :scheduled_at, :status, :notes, photos: [])
    end

    def schedule_params
      params.require(:office_darshan).permit(:scheduled_at, :venue)
    end
  end
end
