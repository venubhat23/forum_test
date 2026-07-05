class CreateSupportTicketReplies < ActiveRecord::Migration[8.0]
  def change
    create_table :support_ticket_replies do |t|
      t.references :support_ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
