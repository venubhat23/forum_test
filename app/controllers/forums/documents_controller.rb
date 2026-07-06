module Forums
  class DocumentsController < BaseController
    before_action :set_document, only: [ :destroy ]

    def index
      authorize! :read, Document
      @documents = @current_forum.documents.order(created_at: :desc).page(params[:page])
    end

    def new
      authorize! :create, Document
      @document = @current_forum.documents.new
    end

    def create
      @document = @current_forum.documents.new(document_params)
      authorize! :create, @document

      if @document.save
        redirect_to forum_documents_path(forum_slug: @current_forum.slug), notice: "Document uploaded."
      else
        flash.now[:alert] = @document.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @document
      @document.destroy
      redirect_to forum_documents_path(forum_slug: @current_forum.slug), notice: "Document deleted."
    end

    private

    def set_document
      @document = @current_forum.documents.find(params[:id])
    end

    def document_params
      params.require(:document).permit(:title, :category, :file)
    end
  end
end
