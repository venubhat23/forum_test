module Forums
  class SupportTicketsController < BaseController
    before_action :set_ticket, only: [ :show, :reply ]

    def index
      @tickets = SupportTicket.where(forum: @current_forum, raised_by: current_user).order(created_at: :desc)
    end

    def new
      @ticket = SupportTicket.new
    end

    def create
      @ticket = SupportTicket.new(ticket_params)
      @ticket.forum = @current_forum
      @ticket.raised_by = current_user

      if @ticket.save
        redirect_to forum_support_ticket_path(forum_slug: @current_forum.slug, id: @ticket.id), notice: "Support ticket submitted."
      else
        flash.now[:alert] = @ticket.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def reply
      @ticket.replies.create!(user: current_user, body: params[:body])
      redirect_to forum_support_ticket_path(forum_slug: @current_forum.slug, id: @ticket.id), notice: "Reply added."
    end

    private

    def set_ticket
      @ticket = SupportTicket.where(forum: @current_forum, raised_by: current_user).find(params[:id])
    end

    def ticket_params
      params.require(:support_ticket).permit(:subject, :body, :priority)
    end
  end
end
