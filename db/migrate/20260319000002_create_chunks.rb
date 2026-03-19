class CreateChunks < ActiveRecord::Migration[8.0]
  def change
    create_table :chunks do |t|
      t.belongs_to :song, null: false, foreign_key: true
      t.text :content, null: false
      t.vector :embedding, limit: 1536

      t.timestamps
    end

    add_index :chunks, :embedding, using: :hnsw, opclass: :vector_cosine_ops
  end
end
