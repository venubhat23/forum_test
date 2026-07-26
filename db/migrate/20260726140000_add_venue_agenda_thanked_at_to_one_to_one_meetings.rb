class AddVenueAgendaThankedAtToOneToOneMeetings < ActiveRecord::Migration[8.0]
  def change
    add_column :one_to_one_meetings, :venue, :string
    add_column :one_to_one_meetings, :agenda, :text
    add_column :one_to_one_meetings, :thanked_at, :datetime
  end
end
