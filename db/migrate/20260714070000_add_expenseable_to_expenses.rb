class AddExpenseableToExpenses < ActiveRecord::Migration[8.0]
  def change
    add_reference :expenses, :expenseable, polymorphic: true, index: true
  end
end
