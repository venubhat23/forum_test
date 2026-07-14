module SuperAdmin
  class InvoicesController < BaseController
    before_action :set_invoice, only: [ :show, :mark_paid, :void ]

    def index
      @total_invoices = Invoice.count
      @paid_invoices = Invoice.where(status: :paid).count
      @pending_invoices = Invoice.where(status: :pending).count
      @overdue_invoices = Invoice.where(status: :overdue).or(Invoice.where("due_date < ? AND status = ?", Date.current, Invoice.statuses[:pending])).count

      @invoices = Invoice.includes(:forum).order(created_at: :desc)
      @invoices = @invoices.where(forum_id: params[:forum_id]) if params[:forum_id].present?
      @invoices = @invoices.where(status: params[:status]) if params[:status].present?
      @invoices = @invoices.page(params[:page])
    end

    def new
      @invoice = Invoice.new(due_date: 7.days.from_now.to_date)
      @forums = Forum.order(:name)
    end

    def create
      @invoice = Invoice.new(invoice_params)

      if params[:coupon_code].present?
        coupon = Coupon.find_by(code: params[:coupon_code].to_s.strip.upcase)
        if coupon&.redeemable?
          @invoice.coupon = coupon
          @invoice.amount = coupon.discounted_amount(@invoice.amount) if @invoice.amount.present?
        end
      end

      if @invoice.save
        @invoice.coupon&.increment!(:times_redeemed)
        redirect_to super_admin_invoice_path(@invoice), notice: "Invoice #{@invoice.invoice_number} created."
      else
        @forums = Forum.order(:name)
        flash.now[:alert] = @invoice.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def mark_paid
      @invoice.mark_paid!(
        payment_method: params[:payment_method].presence || "other",
        recorded_by: current_user,
        reference_number: params[:reference_number]
      )
      redirect_to super_admin_invoice_path(@invoice), notice: "Invoice #{@invoice.invoice_number} marked as paid."
    end

    def void
      @invoice.update!(status: :cancelled)
      redirect_to super_admin_invoice_path(@invoice), notice: "Invoice #{@invoice.invoice_number} cancelled."
    end

    private

    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def invoice_params
      params.require(:invoice).permit(:forum_id, :plan_id, :amount, :due_date, :description)
    end
  end
end
