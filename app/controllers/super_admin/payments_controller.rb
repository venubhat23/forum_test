module SuperAdmin
  class PaymentsController < BaseController
    def index
      @total_payments = Payment.count
      @total_amount = Payment.sum(:amount)
      @this_month_amount = Payment.where(paid_on: Time.current.beginning_of_month..).sum(:amount)

      @payments = Payment.includes(invoice: :forum).order(paid_on: :desc, created_at: :desc)
      @payments = @payments.where(invoices: { forum_id: params[:forum_id] }) if params[:forum_id].present?
      @payments = @payments.page(params[:page])
    end
  end
end
