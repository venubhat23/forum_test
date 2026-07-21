class CreateWhatsappTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :whatsapp_templates do |t|
      t.references :forum, null: true, foreign_key: true
      t.string :key, null: false
      t.text :body, null: false

      t.timestamps
    end

    # Postgres treats NULLs as distinct in a plain unique index, so a bare
    # (forum_id, key) index would silently allow duplicate global (forum_id
    # IS NULL) rows. Two partial indexes enforce uniqueness in both cases.
    add_index :whatsapp_templates, [ :forum_id, :key ], unique: true, where: "forum_id IS NOT NULL",
      name: "index_whatsapp_templates_on_forum_id_and_key"
    add_index :whatsapp_templates, :key, unique: true, where: "forum_id IS NULL",
      name: "index_whatsapp_templates_on_key_when_global"
  end
end
