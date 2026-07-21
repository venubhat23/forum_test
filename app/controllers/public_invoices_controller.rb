class PublicInvoicesController < ApplicationController
  layout false

  rescue_from ActiveRecord::RecordNotFound, with: :invoice_not_found

  def show
    @invoice = Invoice.includes(:forum, :plan, :user, payments: :recorded_by).find_by!(share_token: params[:token])
  end

  private

  def invoice_not_found
    render "public_invoices/not_found", status: :not_found
  end
end
