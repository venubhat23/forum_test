module Forums
  class CommitteeMembersController < BaseController
    before_action :set_chapter
    before_action :set_committee_member, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize! :read, User
      @committee_members = @chapter.committee_members.order(:designation, :full_name).page(params[:page])
    end

    def show
      authorize! :read, @committee_member
    end

    def new
      authorize! :create, User
      @committee_member = @chapter.committee_members.new
    end

    def create
      @committee_member = @chapter.committee_members.new(committee_member_params)
      @committee_member.forum = @current_forum
      @committee_member.role = :committee_member
      authorize! :create, @committee_member

      if @committee_member.save
        redirect_to forum_chapter_committee_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "#{@committee_member.display_name} was added as #{@committee_member.designation}."
      else
        flash.now[:alert] = @committee_member.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @committee_member
    end

    def update
      authorize! :update, @committee_member
      if @committee_member.update(committee_member_update_params)
        redirect_to forum_chapter_committee_member_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @committee_member.id), notice: "#{@committee_member.display_name} was updated."
      else
        flash.now[:alert] = @committee_member.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @committee_member
      @committee_member.update!(role: :member, designation: nil, term_starts_on: nil, term_ends_on: nil, responsibilities: nil)
      redirect_to forum_chapter_committee_members_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "#{@committee_member.display_name} was removed from the committee (kept as a member)."
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_committee_member
      @committee_member = @chapter.committee_members.find(params[:id])
    end

    def committee_member_params
      params.require(:committee_member).permit(:full_name, :email, :phone, :designation, :password, :password_confirmation, :term_starts_on, :term_ends_on, :responsibilities)
    end

    def committee_member_update_params
      params.require(:committee_member).permit(:full_name, :email, :phone, :designation, :term_starts_on, :term_ends_on, :responsibilities)
    end
  end
end
