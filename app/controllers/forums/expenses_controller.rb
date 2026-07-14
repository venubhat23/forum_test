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
      @expenseable = resolve_expenseable
      @expense = @current_forum.expenses.new(incurred_on: Date.current, expenseable: @expenseable)
    end

    def create
      @expense = @current_forum.expenses.new(expense_params.except(:event_id, :meeting_id))
      @expense.expenseable = resolve_expenseable
      authorize! :create, @expense

      if @expense.save
        redirect_to expenseable_redirect_path(@expense.expenseable), notice: "Expense recorded."
      else
        @expenseable = @expense.expenseable
        flash.now[:alert] = @expense.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize! :update, @expense
    end

    def update
      authorize! :update, @expense
      if @expense.update(expense_params.except(:event_id, :meeting_id))
        redirect_to expenseable_redirect_path(@expense.expenseable), notice: "Expense updated."
      else
        flash.now[:alert] = @expense.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :destroy, @expense
      expenseable = @expense.expenseable
      @expense.destroy
      redirect_to expenseable_redirect_path(expenseable), notice: "Expense deleted."
    end

    private

    def set_expense
      @expense = @current_forum.expenses.find(params[:id])
    end

    def resolve_expenseable
      event_id = params[:event_id] || params.dig(:expense, :event_id)
      meeting_id = params[:meeting_id] || params.dig(:expense, :meeting_id)

      return @current_forum.events.find(event_id) if event_id.present?
      return Meeting.joins(:chapter).where(chapters: { forum_id: @current_forum.id }).find(meeting_id) if meeting_id.present?

      nil
    end

    def expenseable_redirect_path(expenseable)
      case expenseable
      when Event
        forum_event_path(forum_slug: @current_forum.slug, id: expenseable.id)
      when Meeting
        forum_chapter_meeting_path(forum_slug: @current_forum.slug, chapter_id: expenseable.chapter_id, id: expenseable.id)
      else
        forum_expenses_path(forum_slug: @current_forum.slug)
      end
    end

    def expense_params
      params.require(:expense).permit(:category, :amount, :incurred_on, :notes, :event_id, :meeting_id)
    end
  end
end
