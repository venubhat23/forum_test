class GuestProfileFormsController < ApplicationController
  before_action :set_guest

  rescue_from ActiveRecord::RecordNotFound, with: :guest_not_found

  def edit
    return render :already_converted unless @guest.guest?

    # Being on a recurring schedule's attendee list never creates individual
    # Attendance rows (MeetingSchedule#notify_attendees only sends a
    # notification), so those invites are shown separately from one-off
    # meeting invites, which do go through Attendance.
    @invited_schedules = @guest.meeting_schedule_attendances.includes(meeting_schedule: :meetings)
      .map(&:meeting_schedule).uniq
    schedule_meeting_ids = @invited_schedules.flat_map { |schedule| schedule.meetings.map(&:id) }

    @invited_meetings = @guest.attendances.where(event_type: :meeting).where.not(meeting_id: nil)
      .includes(:meeting).map(&:meeting).compact.uniq
      .reject { |meeting| schedule_meeting_ids.include?(meeting.id) }
      .sort_by(&:scheduled_at)
  end

  def update
    return render :already_converted unless @guest.guest?

    @guest.assign_attributes(guest_profile_params)
    @guest.profile_submitted_at = Time.current

    if @guest.save
      redirect_to guest_profile_form_path(token: @guest.profile_token), notice: "Thank you! Your information has been saved."
    else
      flash.now[:alert] = @guest.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_guest
    @guest = User.find_by!(profile_token: params[:token])
  end

  def guest_not_found
    render :not_found, status: :not_found
  end

  def guest_profile_params
    # Note: :designation (Committee Role) is deliberately excluded — that's
    # assigned by a chapter admin, not something a guest can self-appoint.
    params.require(:guest).permit(:full_name, :email, :phone, :date_of_birth, :photo, :company_logo,
      :business_name, :business_category, :speciality, :business_category_id,
      :website, :gst_number, :pan_number, :aadhaar_number, :address, :city,
      :service_area, :capacity, :social_media_handle,
      :aadhaar_document, :pan_document, :gst_document,
      :meeting_fee_paid, :meeting_fee_screenshot, kyc_documents: [])
  end
end
