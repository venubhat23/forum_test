module Forums
  class CommitteeMembersController < BaseController
    before_action :set_chapter

    def index
      @committee_members = @chapter.committee_members.order(:designation, :full_name).page(params[:page])
    end

    def new
      @committee_member = @chapter.committee_members.new
    end

    def create
      @committee_member = @chapter.committee_members.new(committee_member_params)
      @committee_member.forum = @current_forum
      @committee_member.role = :committee_member

      if @committee_member.save
        redirect_to forum_chapter_committee_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "#{@committee_member.display_name} was added as #{@committee_member.designation}."
      else
        flash.now[:alert] = @committee_member.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def committee_member_params
      params.require(:committee_member).permit(:full_name, :email, :phone, :designation, :password, :password_confirmation)
    end
  end
end
