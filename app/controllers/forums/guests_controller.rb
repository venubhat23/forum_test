module Forums
  class GuestsController < BaseController
    before_action :set_chapter, except: [ :all ]
    before_action :set_guest, only: [ :show, :edit, :update, :destroy, :convert, :convert_to_member ]

    # Forum-wide guest list, shown chapter-by-chapter. Chapter admins only
    # ever see their own chapter's guests; forum/super admins see all of them.
    def all
      authorize! :read, User
      scope = current_user.chapter_admin? ? @current_forum.guests.where(chapter_id: current_user.chapter_id) : @current_forum.guests

      @total_guests = scope.count
      @guests_this_month = scope.where(created_at: Time.current.beginning_of_month..).count

      @guests = scope.includes(:invited_by, :chapter).order(:full_name)
      @guests = @guests.where("full_name ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @guests = @guests.page(params[:page])
    end

    def index
      authorize! :read, User
      @total_guests = @chapter.guests.count
      @guests_this_month = @chapter.guests.where(created_at: Time.current.beginning_of_month..).count
      @upcoming_event = @current_forum.events.where("starts_at >= ?", Time.current).order(:starts_at).first

      @guests = @chapter.guests.includes(:invited_by).order(:full_name)
      @guests = @guests.where("full_name ILIKE ? OR email ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @guests = @guests.page(params[:page])
    end

    def show
      authorize! :read, @guest
      @visit_count = Attendance.where(user_id: @guest.id).count
      @guest_meeting_fees = @guest.fee_payments.where(fee_type: :meeting).includes(:feeable).order(created_at: :desc)
    end

    def new
      authorize! :create, User
      @guest = @chapter.guests.new
      @upcoming_meetings = @chapter.meetings.where("scheduled_at >= ?", Time.current).order(:scheduled_at)
    end

    def create
      @guest = @chapter.guests.new(guest_params)
      apply_invited_by_selection(@guest)
      @guest.forum = @current_forum
      @guest.role = :guest
      authorize! :create, @guest

      if @guest.save
        invite_to_meeting(@guest)
        redirect_to forum_chapter_guests_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "#{@guest.display_name} was added as a guest."
      else
        @upcoming_meetings = @chapter.meetings.where("scheduled_at >= ?", Time.current).order(:scheduled_at)
        flash.now[:alert] = @guest.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @guest
    end

    def update
      authorize! :update, @guest
      @guest.assign_attributes(guest_update_params)
      apply_invited_by_selection(@guest)
      if @guest.save
        redirect_to forum_chapter_guest_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @guest.id), notice: "#{@guest.display_name} was updated."
      else
        flash.now[:alert] = @guest.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @guest
      @guest.destroy
      redirect_to forum_chapter_guests_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "#{@guest.display_name} was removed."
    end

    # Step 1 of the conversion wizard: the business-details form.
    def convert
      authorize! :update, @guest
    end

    # Step 2: save the full business profile and flip the guest to a member.
    # The member then lands on the "invite to a meeting" screen, then their
    # profile with the "collect membership fee" and "send welcome message"
    # steps still to go.
    def convert_to_member
      authorize! :update, @guest
      @guest.assign_attributes(guest_conversion_params)
      @guest.role = :member
      @guest.converted_at = Time.current

      if @guest.save
        redirect_to invite_to_meeting_forum_chapter_member_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @guest.id),
          notice: "🎉 #{@guest.display_name} is now a member!"
      else
        @guest.role = :guest
        flash.now[:alert] = @guest.errors.full_messages.to_sentence
        render :convert, status: :unprocessable_entity
      end
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_guest
      @guest = @chapter.guests.find(params[:id])
    end

    def guest_params
      params.require(:guest).permit(:full_name, :email, :phone, :nature_of_business,
        :business_category, :speciality)
    end

    def guest_update_params
      guest_params
    end

    # The "Invited By" field lets the guest be attributed to a specific
    # member, or generically to the chapter/forum for walk-in guests with
    # no known individual inviter.
    def apply_invited_by_selection(guest)
      selection = params.dig(:guest, :invited_by_selection).to_s

      case selection
      when "chapter"
        guest.invited_by_id = nil
        guest.invited_by_note = "chapter"
      when "forum"
        guest.invited_by_id = nil
        guest.invited_by_note = "forum"
      when /\Amember_(\d+)\z/
        member_id = $1
        if @chapter.members.exists?(id: member_id)
          guest.invited_by_id = member_id
          guest.invited_by_note = nil
        end
      else
        guest.invited_by_id = nil
        guest.invited_by_note = nil
      end
    end

    # Records the guest as invited to the selected meeting (so it shows up
    # on their profile) and, if the meeting has a fee and the admin asked
    # for it, opens a pending fee for the guest to be reminded/collected.
    def invite_to_meeting(guest)
      meeting_id = params.dig(:guest, :invited_meeting_id)
      return if meeting_id.blank?

      meeting = @chapter.meetings.find_by(id: meeting_id)
      return unless meeting

      guest.attendances.find_or_create_by!(meeting: meeting) do |attendance|
        attendance.event_type = :meeting
        attendance.occurred_on = meeting.scheduled_at.to_date
      end

      if params.dig(:guest, :collect_meeting_fee) == "1" && meeting.fee_amount.present?
        guest.fee_payments.create!(fee_type: :meeting, feeable: meeting, amount: meeting.fee_amount, due_date: meeting.scheduled_at.to_date)
      end
    end

    def guest_conversion_params
      params.require(:guest).permit(:full_name, :email, :phone, :date_of_birth, :photo,
        :business_name, :business_category, :speciality, :business_category_id, :designation,
        :website, :gst_number, :pan_number, :aadhaar_number, :address, :city,
        :service_area, :capacity, :company_logo, :social_media_handle,
        :aadhaar_document, :pan_document, :gst_document, kyc_documents: [])
    end
  end
end
