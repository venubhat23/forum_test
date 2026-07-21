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
      @partially_paid_fees = base.where(status: :partially_paid).count
      @total_amount = base.sum(:amount)

      @fee_payments = base.includes(:user).order(created_at: :desc)
      @fee_payments = @fee_payments.where("users.full_name ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @fee_payments = @fee_payments.where(status: params[:status]) if params[:status].present?
      @fee_payments = @fee_payments.page(params[:page])
    end

    def new
      authorize! :create, FeePayment
      feeable = resolve_feeable
      user = User.find_by(id: params[:user_id])
      if fee_waived_for?(user, params[:fee_type])
        redirect_to forum_chapter_fee_payments_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id),
          alert: "#{user.display_name}'s annual membership fee is already paid — no meeting/event fee is collected." and return
      end
      @fee_payment = FeePayment.new(user_id: params[:user_id], fee_type: params[:fee_type], feeable: feeable, amount: feeable&.fee_amount)
      @people = billable_people
    end

    def create
      @fee_payment = FeePayment.new(fee_payment_params.except(:event_id, :meeting_id, :one_to_one_meeting_id))
      @fee_payment.feeable = resolve_feeable
      authorize! :create, @fee_payment
      if fee_waived_for?(@fee_payment.user, @fee_payment.fee_type)
        redirect_to forum_chapter_fee_payments_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id),
          alert: "#{@fee_payment.user.display_name}'s annual membership fee is already paid — no meeting/event fee is collected." and return
      end
      mark_as_paid = params.dig(:fee_payment, :mark_as_paid) == "1"

      if @fee_payment.user && @fee_payment.user.chapter_id == @chapter.id && @fee_payment.save
        @fee_payment.mark_paid! if mark_as_paid
        notice = mark_as_paid ? "Payment received from #{@fee_payment.user.display_name}. 🎉" : "Fee recorded for #{@fee_payment.user.display_name}."
        destination = if @fee_payment.annual_membership? && @fee_payment.user.member?
          forum_chapter_member_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id, id: @fee_payment.user_id)
        else
          forum_chapter_fee_payments_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id)
        end
        redirect_to destination, notice: notice
      else
        @fee_payment.errors.add(:user, "must belong to this chapter") if @fee_payment.user && @fee_payment.user.chapter_id != @chapter.id
        @people = billable_people
        flash.now[:alert] = @fee_payment.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def mark_paid
      authorize! :update, @fee_payment
      received_amount = params[:amount].presence&.to_d || @fee_payment.balance_due
      @fee_payment.record_payment!(received_amount: received_amount, payment_method: params[:payment_method])

      notice = @fee_payment.paid? ? "Fee marked as paid." : "Partial payment of #{helpers.number_to_currency(received_amount)} recorded. Balance due: #{helpers.number_to_currency(@fee_payment.balance_due)}."
      redirect_to forum_chapter_fee_payments_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), notice: notice
    rescue ArgumentError => e
      redirect_to forum_chapter_fee_payments_path(forum_slug: @current_forum.slug, chapter_id: @chapter.id), alert: e.message
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

    # Members who've already paid their annual dues are never charged a
    # separate meeting/event/training fee — only the annual_membership fee
    # itself can still be collected (e.g. next year's renewal).
    def fee_waived_for?(user, fee_type)
      return false unless user && fee_type
      return false if fee_type.to_s == "annual_membership"

      user.annual_fee_paid?
    end

    def resolve_feeable
      event_id = params[:event_id] || params.dig(:fee_payment, :event_id)
      meeting_id = params[:meeting_id] || params.dig(:fee_payment, :meeting_id)
      one_to_one_meeting_id = params[:one_to_one_meeting_id] || params.dig(:fee_payment, :one_to_one_meeting_id)

      return @current_forum.events.find(event_id) if event_id.present?
      return @chapter.meetings.find(meeting_id) if meeting_id.present?
      return @current_forum.one_to_one_meetings.find(one_to_one_meeting_id) if one_to_one_meeting_id.present?

      nil
    end

    def fee_payment_params
      params.require(:fee_payment).permit(:user_id, :fee_type, :amount, :due_date, :event_id, :meeting_id, :one_to_one_meeting_id, :duration_years, :lifetime)
    end
  end
end
