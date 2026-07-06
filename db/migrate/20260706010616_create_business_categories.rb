class CreateBusinessCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :business_categories do |t|
      t.references :forum, null: false, foreign_key: true
      t.string :name, null: false
      t.bigint :parent_id

      t.timestamps
    end
    add_index :business_categories, :parent_id
    add_foreign_key :business_categories, :business_categories, column: :parent_id
    add_foreign_key :users, :business_categories, column: :business_category_id
  end
end
