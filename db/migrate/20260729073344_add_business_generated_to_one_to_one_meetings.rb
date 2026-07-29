class AddBusinessGeneratedToOneToOneMeetings < ActiveRecord::Migration[8.0]
  def change
    add_column :one_to_one_meetings, :business_generated, :boolean, default: false, null: false
    add_column :one_to_one_meetings, :business_generated_amount, :decimal, precision: 10, scale: 2
  end
end
