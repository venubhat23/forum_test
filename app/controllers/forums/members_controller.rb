module Forums
  class MembersController < BaseController
    before_action :set_chapter

    def index
      @members = @chapter.members.order(:full_name).page(params[:page])
    end

    def new
      @member = @chapter.members.new
    end

    def create
      @member = @chapter.members.new(member_params)
      @member.forum = @current_forum
      @member.role = :member

      if @member.save
        redirect_to forum_chapter_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "#{@member.display_name} was added as a member."
      else
        flash.now[:alert] = @member.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def member_params
      params.require(:member).permit(:full_name, :email, :phone, :password, :password_confirmation,
        :business_name, :business_category, :speciality)
    end
  end
end
