module SuperAdmin
  class PaymentsController < BaseController
    def index
      @payments = Payment.includes(invoice: :forum).order(paid_on: :desc, created_at: :desc)
      @payments = @payments.where(invoices: { forum_id: params[:forum_id] }) if params[:forum_id].present?
      @payments = @payments.page(params[:page])
    end
  end
end
