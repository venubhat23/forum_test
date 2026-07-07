module Forums
  class FeePaymentsController < BaseController
    before_action :set_chapter
    before_action :set_fee_payment, only: [ :mark_paid, :print ]

    def index
      authorize! :read, FeePayment
      base = FeePayment.joins(:user).where(users: { chapter_id: @chapter.id })
      @total_fees = base.count
      @paid_fees = base.where(status: :paid).count
      @pending_fees = base.where(status: :pending).count
      @total_amount = base.sum(:amount)

      @fee_payments = base.order(created_at: :desc)
      @fee_payments = @fee_payments.where("users.full_name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @fee_payments = @fee_payments.where(status: params[:status]) if params[:status].present?
      @fee_payments = @fee_payments.page(params[:page])
    end

    def new
      authorize! :create, FeePayment
      @fee_payment = FeePayment.new
      @people = billable_people
    end

    def create
      @fee_payment = FeePayment.new(fee_payment_params)
      authorize! :create, @fee_payment

      if @fee_payment.user && @fee_payment.user.chapter_id == @chapter.id && @fee_payment.save
        redirect_to forum_chapter_fee_payments_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "Fee recorded for #{@fee_payment.user.display_name}."
      else
        @fee_payment.errors.add(:user, "must belong to this chapter") if @fee_payment.user && @fee_payment.user.chapter_id != @chapter.id
        @people = billable_people
        flash.now[:alert] = @fee_payment.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def mark_paid
      authorize! :update, @fee_payment
      @fee_payment.mark_paid!(payment_method: params[:payment_method])
      redirect_to forum_chapter_fee_payments_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: "Fee marked as paid."
    end

    def print
      authorize! :read, @fee_payment
      render layout: false
    end

    private

    def set_chapter
      @chapter = @current_forum.chapters.find(params[:chapter_id])
    end

    def set_fee_payment
      @fee_payment = FeePayment.joins(:user).where(users: { chapter_id: @chapter.id }).find(params[:id])
    end

    def billable_people
      @chapter.users.where(role: [ :member, :guest ]).order(:full_name)
    end

    def fee_payment_params
      params.require(:fee_payment).permit(:user_id, :fee_type, :amount, :due_date)
    end
  end
end
