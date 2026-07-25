class AddBillingDetailsToForums < ActiveRecord::Migration[8.0]
  def change
    add_column :forums, :gst_number, :string
    add_column :forums, :address, :text
    add_column :forums, :office, :string
  end
end
