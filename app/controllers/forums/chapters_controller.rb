module Forums
  class ChaptersController < BaseController
    before_action :set_chapter, only: [ :show, :edit, :update, :destroy, :activate, :assign_admin ]

    def index
      authorize! :read, Chapter
      @chapters = @current_forum.chapters.order(:name).page(params[:page])
    end

    def show
      authorize! :read, @chapter
    end

    def new
      authorize! :create, Chapter
      @chapter = @current_forum.chapters.new
    end

    def create
      @chapter = @current_forum.chapters.new(chapter_params)
      authorize! :create, @chapter
      if @chapter.save
        redirect_to forum_chapters_path(forum_slug: @current_forum.slug), notice: "#{@chapter.name} chapter was created."
      else
        flash.now[:alert] = @chapter.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @chapter
    end

    def update
      authorize! :update, @chapter
      if @chapter.update(chapter_params)
        redirect_to forum_chapter_path(forum_slug: @current_forum.slug, id: @chapter.id), notice: "#{@chapter.name} was updated."
      else
        flash.now[:alert] = @chapter.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @chapter
      @chapter.update!(status: :inactive)
      redirect_to forum_chapters_path(forum_slug: @current_forum.slug), notice: "#{@chapter.name} was deactivated."
    end

    def activate
      authorize! :destroy, @chapter
      @chapter.update!(status: :active)
      redirect_to forum_chapter_path(forum_slug: @current_forum.slug, id: @chapter.id), notice: "#{@chapter.name} was activated."
    end

    def assign_admin
      authorize! :assign_admin, @chapter
      candidate = @chapter.users.find(params[:user_id])
      candidate.update!(role: :chapter_admin)
      redirect_to forum_chapter_path(forum_slug: @current_forum.slug, id: @chapter.id), notice: "#{candidate.display_name} is now the Chapter Admin."
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:id])
    end

    def chapter_params
      params.require(:chapter).permit(:name)
    end
  end
end
