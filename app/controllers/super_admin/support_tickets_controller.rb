module SuperAdmin
  class SupportTicketsController < BaseController
    before_action :set_ticket, only: [ :show, :reply, :change_status ]

    def index
      @total_tickets = SupportTicket.count
      @open_tickets = SupportTicket.where(status: [ :open, :in_progress ]).count
      @closed_tickets = SupportTicket.where(status: [ :resolved, :closed ]).count

      @tickets = SupportTicket.includes(:forum, :raised_by).order(created_at: :desc)
      @tickets = @tickets.where(status: params[:status]) if params[:status].present?
    end

    def show
    end

    def reply
      @ticket.replies.create!(user: current_user, body: params[:body])
      redirect_to super_admin_support_ticket_path(@ticket), notice: "Reply added."
    end

    def change_status
      @ticket.update!(status: params[:status])
      redirect_to super_admin_support_ticket_path(@ticket), notice: "Status updated to #{@ticket.status.titleize}."
    end

    private

    def set_ticket
      @ticket = SupportTicket.find(params[:id])
    end
  end
end
