module Forums
  class LedgerController < BaseController
    def show
      authorize! :read, Expense

      @from = parse_date(params[:from]) || Date.current.beginning_of_year
      @to = parse_date(params[:to]) || Date.current

      user_ids = @current_forum.users.pluck(:id)

      credit_transactions = FeePaymentTransaction
        .joins(:fee_payment)
        .where(fee_payments: { user_id: user_ids })
        .includes(fee_payment: [ :user, :feeable ])

      debit_expenses = @current_forum.expenses

      @opening_balance = credit_transactions.where("fee_payment_transactions.paid_on < ?", @from).sum("fee_payment_transactions.amount") -
        debit_expenses.where("incurred_on < ?", @from).sum(:amount)

      entries = []

      credit_transactions.where(fee_payment_transactions: { paid_on: @from..@to }).find_each do |txn|
        fee = txn.fee_payment
        label = fee.fee_type.titleize
        label += " · #{fee.feeable.title}" if fee.feeable.respond_to?(:title) && fee.feeable.title.present?

        entries << {
          date: txn.paid_on,
          description: label,
          party: fee.user.display_name,
          kind: :credit,
          amount: txn.amount
        }
      end

      debit_expenses.where(incurred_on: @from..@to).find_each do |expense|
        entries << {
          date: expense.incurred_on,
          description: expense.category,
          party: expense.notes.presence || "—",
          kind: :debit,
          amount: expense.amount
        }
      end

      entries.sort_by! { |e| [ e[:date], e[:kind] == :credit ? 0 : 1 ] }

      running_balance = @opening_balance
      @entries = entries.map do |entry|
        running_balance += entry[:kind] == :credit ? entry[:amount] : -entry[:amount]
        entry.merge(balance: running_balance)
      end

      @total_credits = entries.select { |e| e[:kind] == :credit }.sum { |e| e[:amount] }
      @total_debits = entries.select { |e| e[:kind] == :debit }.sum { |e| e[:amount] }
      @closing_balance = @opening_balance + @total_credits - @total_debits
    end

    private

    def parse_date(value)
      Date.parse(value) if value.present?
    rescue ArgumentError
      nil
    end
  end
end
