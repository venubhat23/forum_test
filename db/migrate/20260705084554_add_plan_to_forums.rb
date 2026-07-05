class AddPlanToForums < ActiveRecord::Migration[8.0]
  def change
    add_column :forums, :plan, :integer, default: 0, null: false
  end
end
