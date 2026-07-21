module Forums
  class MeetingsController < BaseController
    before_action :set_chapter
    before_action :set_meeting, only: [ :show, :edit, :update, :destroy, :remind, :attendance, :record_attendance, :check_in ]

    def index
      authorize! :read, Meeting
      all_meetings = @chapter.meetings.to_a
      @total_meetings = all_meetings.size
      @attendance_percentages = Meeting.attendance_percentages(all_meetings, @chapter)
      @avg_attendance = @attendance_percentages.any? ? (@attendance_percentages.values.sum / @attendance_percentages.size.to_f).round(1) : 0

      @meetings = @chapter.meetings.order(scheduled_at: :desc)
      @meetings = @meetings.where("venue ILIKE ? OR speaker ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @meetings = @meetings.where(meeting_type: params[:meeting_type]) if params[:meeting_type].present?
      @meetings = @meetings.page(params[:page])
    end

    def show
      authorize! :read, @meeting
    end

    def new
      authorize! :create, Meeting
      @meeting = @chapter.meetings.new(scheduled_at: Time.current)
    end

    def create
      @meeting = @chapter.meetings.new(meeting_params)
      authorize! :create, @meeting

      if @meeting.save
        redirect_to forum_chapter_meeting_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @meeting.id), notice: "Meeting scheduled."
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
        redirect_to forum_chapter_meeting_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @meeting.id), notice: "Meeting updated."
      else
        flash.now[:alert] = @meeting.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @meeting
      @meeting.destroy
      redirect_to forum_chapter_meetings_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "Meeting deleted."
    end

    def remind
      authorize! :update, @meeting

      if @meeting.fee_amount.present?
        paid_user_ids = @meeting.fee_payments.paid.pluck(:user_id)
        recipients = @chapter.members.where.not(id: paid_user_ids)
        amount_text = " Fee: #{helpers.number_to_currency(@meeting.fee_amount)} — see the meeting page for payment details."
      else
        recipients = @chapter.members
        amount_text = ""
      end

      message = "Reminder: the #{@meeting.meeting_type} meeting on #{@meeting.scheduled_at.strftime('%d %b %Y at %I:%M %p')} is coming up.#{amount_text}"
      sent_count = recipients.count
      recipients.find_each { |member| member.notifications.create!(body: message) }

      redirect_to forum_chapter_meeting_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @meeting.id), notice: "Reminder sent to #{sent_count} member(s)."
    end

    def attendance
      authorize! :update, @meeting
      @attendance_by_user = @meeting.attendances.index_by(&:user_id)
      @people = attendable_people
    end

    def record_attendance
      authorize! :update, @meeting
      present_ids = Array(params[:present_user_ids]).map(&:to_i)

      attendable_people.each do |person|
        record = @meeting.attendances.find_or_initialize_by(user_id: person.id)
        record.event_type = :meeting
        record.occurred_on = @meeting.scheduled_at.to_date
        record.present = present_ids.include?(person.id)
        record.save!
      end

      redirect_to forum_chapter_meeting_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @meeting.id),
        notice: "Attendance recorded for #{attendable_people.count} people."
    end

    # Self check-in: a member/guest marks themselves present for their own
    # chapter's meeting, but only on the meeting day itself.
    def check_in
      authorize! :create, Attendance
      raise CanCan::AccessDenied, "You can only check in to your own chapter's meeting." unless @meeting.chapter_id == current_user.chapter_id

      unless @meeting.scheduled_at.to_date == Date.current
        return redirect_to forum_my_attendance_path(forum_slug: @current_forum.slug), alert: "You can only mark attendance on the day of the meeting."
      end

      record = @meeting.attendances.find_or_initialize_by(user_id: current_user.id)
      record.event_type = :meeting
      record.occurred_on = Date.current
      record.present = true
      record.save!

      redirect_to forum_my_attendance_path(forum_slug: @current_forum.slug), notice: "Attendance marked for today's meeting."
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_meeting
      @meeting = @chapter.meetings.find(params[:id])
    end

    def attendable_people
      @chapter.users.where(role: [ :member, :guest ]).order(:full_name)
    end

    def meeting_params
      params.require(:meeting).permit(:meeting_type, :scheduled_at, :venue, :speaker, :speaker_phone, :agenda, :minutes,
        :fee_amount, :payment_upi_id, :payment_bank_details, :payment_qr, documents: [])
    end
  end
end
