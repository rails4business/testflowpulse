class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
  t.references :user, null: false, foreign_key: true

  t.string :title
  t.string :slug, null: false
  t.text :description

  t.string :img_square_url
  t.string :img_vertical_url
  t.string :img_orizontal_url

  t.datetime :published_at
  t.references :group, polymorphic: true, null: true

  t.jsonb :meta

  # Metti i timestamps PRIMA, così created_at è disponibile
  t.timestamps

  # Colonna generata (PostgreSQL 12+): published_at oppure created_at
  t.datetime :sort_published_or_created,
             as: "COALESCE(published_at, created_at)",
             stored: true
end

add_index :posts, :slug, unique: true
add_index :posts, :meta, using: :gin
add_index :posts, :published_at
add_index :posts, :updated_at
add_index :posts, :created_at
add_index :posts, :sort_published_or_created


    # 🔹 Estensione e indici per ricerca testuale (facoltativo ma consigliato)
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")
    add_index :posts, :title, using: :gin, opclass: :gin_trgm_ops
    add_index :posts, :description, using: :gin, opclass: :gin_trgm_ops
  end
end
