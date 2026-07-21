class AddFeeAmountToOneToOneMeetings < ActiveRecord::Migration[8.0]
  def change
    add_column :one_to_one_meetings, :fee_amount, :decimal, precision: 10, scale: 2
  end
end
