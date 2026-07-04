module Forums
  class ChaptersController < BaseController
    before_action :set_chapter, only: [ :show ]

    def index
      @chapters = @current_forum.chapters.order(:name)
    end

    def show
    end

    def new
      @chapter = @current_forum.chapters.new
    end

    def create
      @chapter = @current_forum.chapters.new(chapter_params)
      if @chapter.save
        redirect_to forum_chapters_path(forum_slug: @current_forum.slug), notice: "#{@chapter.name} chapter was created."
      else
        flash.now[:alert] = @chapter.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
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
