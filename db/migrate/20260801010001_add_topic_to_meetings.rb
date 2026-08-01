class AddTopicToMeetings < ActiveRecord::Migration[8.0]
  def change
    add_column :meetings, :topic, :string
  end
end
