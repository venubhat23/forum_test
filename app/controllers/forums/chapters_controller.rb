module Forums
  class ChaptersController < BaseController
    before_action :set_chapter, only: [ :show, :edit, :update, :destroy, :destroy_permanently, :activate, :assign_admin ]

    def index
      authorize! :read, Chapter
      @total_chapters = @current_forum.chapters.count
      @active_chapters = @current_forum.chapters.active.count
      @inactive_chapters = @current_forum.chapters.inactive.count

      @chapters = @current_forum.chapters.order(:name)
      @chapters = @chapters.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @chapters = @chapters.where(status: params[:status]) if params[:status].present?
      @chapters = @chapters.page(params[:page])
      @chapter_collected_amounts = Hash.new(0).merge(
        FeePayment.joins(:user).where(users: { chapter_id: @chapters.map(&:id) }, status: :paid).group("users.chapter_id").sum(:amount)
      )
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

    def destroy_permanently
      authorize! :destroy, @chapter
      name = @chapter.name
      @chapter.purge!
      redirect_to forum_chapters_path(forum_slug: @current_forum.slug), notice: "#{name} and all its members and data have been permanently deleted."
    rescue ActiveRecord::InvalidForeignKey, ActiveRecord::RecordNotDestroyed => e
      redirect_to forum_chapters_path(forum_slug: @current_forum.slug), alert: "Could not delete #{name}: #{e.message}"
    end

    def bulk_destroy_permanently
      authorize! :destroy, Chapter
      deleted = []
      failed = []
      @current_forum.chapters.where(id: params[:chapter_ids]).find_each do |chapter|
        name = chapter.name
        begin
          chapter.purge!
          deleted << name
        rescue ActiveRecord::InvalidForeignKey, ActiveRecord::RecordNotDestroyed => e
          failed << "#{name} (#{e.message})"
        end
      end

      redirect_to forum_chapters_path(forum_slug: @current_forum.slug),
        notice: (deleted.any? ? "Permanently deleted: #{deleted.join(', ')}." : nil),
        alert: (failed.any? ? "Could not delete: #{failed.join('; ')}." : nil)
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
