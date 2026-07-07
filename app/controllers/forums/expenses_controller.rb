module Forums
  class ExpensesController < BaseController
    before_action :set_expense, only: [ :edit, :update, :destroy ]

    def index
      authorize! :read, Expense
      @total_expenses = @current_forum.expenses.count
      @total_amount = @current_forum.expenses.sum(:amount)

      @expenses = @current_forum.expenses.order(incurred_on: :desc)
      @expenses = @expenses.where("category ILIKE ?", "%#{params[:q]}%") if params[:q].present?
      @expenses = @expenses.page(params[:page])
    end

    def new
      authorize! :create, Expense
      @expense = @current_forum.expenses.new(incurred_on: Date.current)
    end

    def create
      @expense = @current_forum.expenses.new(expense_params)
      authorize! :create, @expense

      if @expense.save
        redirect_to forum_expenses_path(forum_slug: @current_forum.slug), notice: "Expense recorded."
      else
        flash.now[:alert] = @expense.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @expense
    end

    def update
      authorize! :update, @expense
      if @expense.update(expense_params)
        redirect_to forum_expenses_path(forum_slug: @current_forum.slug), notice: "Expense updated."
      else
        flash.now[:alert] = @expense.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @expense
      @expense.destroy
      redirect_to forum_expenses_path(forum_slug: @current_forum.slug), notice: "Expense deleted."
    end

    private

    def set_expense
      @expense = @current_forum.expenses.find(params[:id])
    end

    def expense_params
      params.require(:expense).permit(:category, :amount, :incurred_on, :notes)
    end
  end
end
