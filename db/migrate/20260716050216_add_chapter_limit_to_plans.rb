class AddChapterLimitToPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :plans, :chapter_limit, :integer
  end
end
