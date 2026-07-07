module Forums
  class AttendancesController < BaseController
    before_action :set_chapter

    def index
      authorize! :read, Attendance
      base = Attendance.joins(:user).where(users: { chapter_id: @chapter.id })
      @total_attendance = base.count
      @present_count = base.where(present: true).count
      @absent_count = base.where(present: false).count

      @attendances = base.order(occurred_on: :desc)
      @attendances = @attendances.where("users.full_name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @attendances = @attendances.where(present: true) if params[:status] == "present"
      @attendances = @attendances.where(present: false) if params[:status] == "absent"
      @attendances = @attendances.page(params[:page])
    end

    def new
      authorize! :create, Attendance
      @attendance = Attendance.new(occurred_on: Date.current)
      @people = attendable_people
    end

    def create
      @attendance = Attendance.new(attendance_params)
      authorize! :create, @attendance

      if @attendance.user && @attendance.user.chapter_id == @chapter.id && @attendance.save
        redirect_to forum_chapter_attendances_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "Attendance recorded for #{@attendance.user.display_name}."
      else
        @attendance.errors.add(:user, "must belong to this chapter") if @attendance.user && @attendance.user.chapter_id != @chapter.id
        @people = attendable_people
        flash.now[:alert] = @attendance.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def attendable_people
      @chapter.users.where(role: [ :member, :guest ]).order(:full_name)
    end

    def attendance_params
      params.require(:attendance).permit(:user_id, :event_type, :occurred_on, :present)
    end
  end
end
