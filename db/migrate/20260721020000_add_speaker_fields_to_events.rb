class AddSpeakerFieldsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :speaker, :string
    add_column :events, :speaker_phone, :string
  end
end
