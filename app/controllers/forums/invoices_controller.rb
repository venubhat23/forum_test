module Forums
  class InvoicesController < BaseController
    before_action :set_invoice, only: [ :show, :edit, :update, :destroy, :mark_paid, :void ]

    def index
      authorize! :read, Invoice
      base = Invoice.accessible_by(current_ability).where(forum_id: @current_forum.id).where.not(user_id: nil)
      @total_invoices = base.count
      @paid_invoices = base.where(status: :paid).count
      @pending_invoices = base.where(status: :pending).count
      @partially_paid_invoices = base.where(status: :partially_paid).count
      @overdue_invoices = base.where(status: :overdue).or(base.where("due_date < ? AND status = ?", Date.current, Invoice.statuses[:pending])).count

      @invoices = base.includes(:user).order(created_at: :desc)
      @invoices = @invoices.where(user_id: params[:user_id]) if params[:user_id].present?
      @invoices = @invoices.where(status: params[:status]) if params[:status].present?
      @invoices = @invoices.page(params[:page])
    end

    def new
      authorize! :create, Invoice
      @invoice = Invoice.new(due_date: 7.days.from_now.to_date, user_id: params[:user_id])
      @members = billable_members
    end

    def create
      @invoice = Invoice.new(invoice_params)
      @invoice.forum_id = @invoice.user&.forum_id

      if @invoice.user.nil?
        @invoice.errors.add(:user, "must be selected")
        @members = billable_members
        flash.now[:alert] = @invoice.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
        return
      end

      authorize! :create, @invoice

      if @invoice.save
        redirect_to forum_invoice_path(forum_slug: @current_forum.slug, id: @invoice), notice: "Invoice #{@invoice.invoice_number} created."
      else
        @members = billable_members
        flash.now[:alert] = @invoice.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def show
      authorize! :read, @invoice
      @invoice.regenerate_share_token if @invoice.share_token.blank?
    end

    def edit
      authorize! :update, @invoice
      if @invoice.locked_for_edits?
        redirect_to forum_invoice_path(forum_slug: @current_forum.slug, id: @invoice), alert: "Invoice #{@invoice.invoice_number} can't be edited because a payment has already been recorded against it."
        return
      end
      @members = billable_members
    end

    def update
      authorize! :update, @invoice
      if @invoice.locked_for_edits?
        redirect_to forum_invoice_path(forum_slug: @current_forum.slug, id: @invoice), alert: "Invoice #{@invoice.invoice_number} can't be edited because a payment has already been recorded against it."
        return
      end

      if @invoice.update(invoice_params.except(:user_id))
        redirect_to forum_invoice_path(forum_slug: @current_forum.slug, id: @invoice), notice: "Invoice #{@invoice.invoice_number} updated."
      else
        @members = billable_members
        flash.now[:alert] = @invoice.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @invoice
      if @invoice.locked_for_edits?
        redirect_to forum_invoice_path(forum_slug: @current_forum.slug, id: @invoice), alert: "Invoice #{@invoice.invoice_number} can't be deleted because a payment has already been recorded against it."
        return
      end

      invoice_number = @invoice.invoice_number
      @invoice.destroy
      redirect_to forum_invoices_path(forum_slug: @current_forum.slug), notice: "Invoice #{invoice_number} deleted."
    end

    def mark_paid
      authorize! :update, @invoice
      received_amount = params[:amount].presence&.to_d || @invoice.balance_due
      @invoice.record_payment!(
        received_amount: received_amount,
        payment_method: params[:payment_method].presence || "other",
        recorded_by: current_user,
        reference_number: params[:reference_number]
      )

      notice = @invoice.paid? ? "Invoice #{@invoice.invoice_number} marked as paid." : "Partial payment of #{helpers.number_to_currency(received_amount, unit: '₹', format: '%u%n')} recorded. Balance due: #{helpers.number_to_currency(@invoice.balance_due, unit: '₹', format: '%u%n')}."
      redirect_to forum_invoice_path(forum_slug: @current_forum.slug, id: @invoice), notice: notice
    rescue ArgumentError => e
      redirect_to forum_invoice_path(forum_slug: @current_forum.slug, id: @invoice), alert: e.message
    end

    def void
      authorize! :update, @invoice
      @invoice.update!(status: :cancelled)
      redirect_to forum_invoice_path(forum_slug: @current_forum.slug, id: @invoice), notice: "Invoice #{@invoice.invoice_number} cancelled."
    end

    private

    def set_invoice
      @invoice = Invoice.where(forum_id: @current_forum.id).where.not(user_id: nil).find(params[:id])
    end

    # Forum admins can bill anyone in their forum; chapter admins are
    # restricted to members and guests within their own chapter.
    def billable_members
      base = current_user.chapter_admin? ? Chapter.find(current_user.chapter_id).users : @current_forum.users
      base.where(role: [ :member, :guest ]).order(:full_name)
    end

    def invoice_params
      params.require(:invoice).permit(:user_id, :amount, :due_date, :description)
    end
  end
end
