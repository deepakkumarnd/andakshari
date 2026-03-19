class ChangeEmbeddingDimensionOnChunks < ActiveRecord::Migration[8.0]
  def change
    remove_index :chunks, :embedding
    change_column :chunks, :embedding, :vector, limit: 768
    add_index :chunks, :embedding, using: :hnsw, opclass: :vector_cosine_ops
  end
end
