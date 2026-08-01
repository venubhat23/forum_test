class AddWebsiteTemplateToForumSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :forum_settings, :website_template, :string, default: "classic", null: false
  end
end
