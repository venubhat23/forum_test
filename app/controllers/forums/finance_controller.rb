require "csv"

module Forums
  class FinanceController < BaseController
    def show
      authorize! :read, Expense
      user_ids = @current_forum.users.pluck(:id)
      @income = FeePayment.where(user_id: user_ids, status: :paid).sum(:amount)
      @outstanding = FeePayment.where(user_id: user_ids, status: :pending).sum(:amount)
      @expenses_total = @current_forum.expenses.sum(:amount)
      @net = @income - @expenses_total
      @recent_payments = FeePayment.where(user_id: user_ids, status: :paid).order(paid_on: :desc).limit(10)
      @recent_expenses = @current_forum.expenses.order(incurred_on: :desc).limit(10)

      respond_to do |format|
        format.html
        format.csv { send_data finance_csv, filename: "finance-#{@current_forum.slug}-#{Date.current}.csv" }
      end
    end

    private

    def finance_csv
      user_ids = @current_forum.users.pluck(:id)
      CSV.generate(headers: true) do |csv|
        csv << [ "Type", "Category", "Amount", "Date" ]
        FeePayment.where(user_id: user_ids, status: :paid).find_each do |fee|
          csv << [ "Income", fee.fee_type.titleize, fee.amount, fee.paid_on ]
        end
        @current_forum.expenses.find_each do |expense|
          csv << [ "Expense", expense.category, expense.amount, expense.incurred_on ]
        end
      end
    end
  end
end
