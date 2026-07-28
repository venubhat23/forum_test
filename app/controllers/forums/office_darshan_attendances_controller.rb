module Forums
  class OfficeDarshanAttendancesController < BaseController
    before_action :set_darshan
    before_action :set_attendance

    def rsvp
      authorize! :update, @attendance
      status = params[:rsvp_status] == "not_coming" ? :not_coming : :coming
      @attendance.update!(rsvp_status: status, responded_at: Time.current)
      notice = status == :coming ? "Thanks — you're marked as coming!" : "Got it — you're marked as not coming."
      redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: notice
    end

    def mark_attended
      authorize! :update, @attendance
      unless @darshan.completed?
        return redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), alert: "This visit hasn't been completed yet."
      end
      if @attendance.attended?
        return redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), alert: "You're already marked as attended."
      end

      @attendance.update!(attended: true, attended_at: Time.current)
      redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Thanks — you're marked as attended!"
    end

    def review
      authorize! :update, @attendance
      unless @darshan.completed? && @attendance.attended?
        return redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), alert: "You can only review a visit you attended, after it's completed."
      end

      if @attendance.update(review_params.merge(reviewed_at: Time.current))
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), notice: "Thanks for your feedback!"
      else
        redirect_to forum_office_darshan_path(forum_slug: @current_forum.slug, id: @darshan.id), alert: @attendance.errors.full_messages.to_sentence
      end
    end

    private

    def set_darshan
      @darshan = @current_forum.office_darshans.find(params[:office_darshan_id])
    end

    def set_attendance
      @attendance = @darshan.attendances.find(params[:id])
    end

    def review_params
      params.require(:office_darshan_attendance).permit(:rating, :review_comment)
    end
  end
end
