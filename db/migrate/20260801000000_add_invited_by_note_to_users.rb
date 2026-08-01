class AddInvitedByNoteToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :invited_by_note, :string
  end
end
