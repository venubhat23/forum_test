module Forums
  class BusinessCategoriesController < BaseController
    before_action :set_category, only: [ :edit, :update, :destroy ]

    def index
      authorize! :read, BusinessCategory
      @top_level = @current_forum.business_categories.top_level.includes(:children).order(:name)
    end

    def new
      authorize! :create, BusinessCategory
      @category = @current_forum.business_categories.new(parent_id: params[:parent_id])
    end

    def create
      @category = @current_forum.business_categories.new(category_params)
      authorize! :create, @category
      if @category.save
        redirect_to forum_business_categories_path(forum_slug: @current_forum.slug), notice: "#{@category.name} was created."
      else
        flash.now[:alert] = @category.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @category
    end

    def update
      authorize! :update, @category
      if @category.update(category_params)
        redirect_to forum_business_categories_path(forum_slug: @current_forum.slug), notice: "#{@category.name} was updated."
      else
        flash.now[:alert] = @category.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @category
      @category.destroy
      redirect_to forum_business_categories_path(forum_slug: @current_forum.slug), notice: "#{@category.name} was deleted."
    end

    private

    def set_category
      @category = @current_forum.business_categories.find(params[:id])
    end

    def category_params
      params.require(:business_category).permit(:name, :parent_id)
    end
  end
end
