class AddSpeakerPhoneToMeetings < ActiveRecord::Migration[8.0]
  def change
    add_column :meetings, :speaker_phone, :string
  end
end
