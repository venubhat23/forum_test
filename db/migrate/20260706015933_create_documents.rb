class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :forum, null: false, foreign_key: true
      t.string :title, null: false
      t.string :category
      t.references :documentable, polymorphic: true, null: true

      t.timestamps
    end
  end
end
