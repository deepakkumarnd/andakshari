class AddFulltextIndexOnChunksContent < ActiveRecord::Migration[8.0]
  def change
    add_index :chunks, "to_tsvector('simple', content)", using: :gin, name: "index_chunks_on_content_fulltext"
  end
end
