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
      feeable = resolve_feeable
      @fee_payment = FeePayment.new(user_id: params[:user_id], fee_type: params[:fee_type], feeable: feeable, amount: feeable&.fee_amount)
      @people = billable_people
    end

    def create
      @fee_payment = FeePayment.new(fee_payment_params.except(:event_id, :meeting_id))
      @fee_payment.feeable = resolve_feeable
      authorize! :create, @fee_payment

      if params.dig(:fee_payment, :mark_as_paid) == "1"
        @fee_payment.status = :paid
        @fee_payment.paid_on = Date.current
      end

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

    def resolve_feeable
      event_id = params[:event_id] || params.dig(:fee_payment, :event_id)
      meeting_id = params[:meeting_id] || params.dig(:fee_payment, :meeting_id)

      return @current_forum.events.find(event_id) if event_id.present?
      return @chapter.meetings.find(meeting_id) if meeting_id.present?

      nil
    end

    def fee_payment_params
      params.require(:fee_payment).permit(:user_id, :fee_type, :amount, :due_date, :event_id, :meeting_id)
    end
  end
end
