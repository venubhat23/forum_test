module Forums
  class WeeklyPresentationsController < BaseController
    before_action :set_chapter
    before_action :set_presentation, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize! :read, WeeklyPresentation
      @total_presentations = @chapter.weekly_presentations.count

      @presentations = @chapter.weekly_presentations.order(scheduled_on: :desc)
      @presentations = @presentations.joins(:member).where("users.full_name ILIKE ? OR weekly_presentations.topic ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?
      @presentations = @presentations.page(params[:page])
    end

    def show
      authorize! :read, @presentation
    end

    def new
      authorize! :create, WeeklyPresentation
      @presentation = @chapter.weekly_presentations.new(scheduled_on: Date.current)
    end

    def create
      @presentation = @chapter.weekly_presentations.new(presentation_params)
      authorize! :create, @presentation

      if @presentation.save
        redirect_to forum_chapter_weekly_presentation_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @presentation.id), notice: "Presentation scheduled."
      else
        flash.now[:alert] = @presentation.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @presentation
    end

    def update
      authorize! :update, @presentation
      if @presentation.update(presentation_params)
        redirect_to forum_chapter_weekly_presentation_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @presentation.id), notice: "Presentation updated."
      else
        flash.now[:alert] = @presentation.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @presentation
      @presentation.destroy
      redirect_to forum_chapter_weekly_presentations_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "Presentation deleted."
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_presentation
      @presentation = @chapter.weekly_presentations.find(params[:id])
    end

    def presentation_params
      params.require(:weekly_presentation).permit(:member_id, :meeting_id, :topic, :scheduled_on, :feedback, :deck)
    end
  end
end
