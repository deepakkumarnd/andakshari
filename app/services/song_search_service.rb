class SongSearchService
  TOP_K = 5

  def self.search(query)
    new(query).search
  end

  def initialize(query)
    @query = query
  end

  def search
    embedding = EmbeddingService.embed_many([ @query ]).first

    vector_results = vector_search(embedding)  # [{ song_id:, match: }]
    text_song_ids  = text_search_song_ids

    vector_song_ids = vector_results.map { |r| r[:song_id] }
    both = vector_song_ids & text_song_ids

    vector_results.map do |r|
      { song_id: r[:song_id], match: r[:match], top_result: both.include?(r[:song_id]) }
    end.sort_by { |r| [ r[:top_result] ? 0 : 1, -r[:match] ] }
  end

  private

  def vector_search(embedding)
    vector_literal = "[#{embedding.join(',')}]"
    sql = <<~SQL
      SELECT song_id,
             ROUND(((1 - MIN(embedding <=> '#{vector_literal}'::vector)) * 100)::numeric, 2) AS match
      FROM chunks
      GROUP BY song_id
      ORDER BY MIN(embedding <=> '#{vector_literal}'::vector)
      LIMIT #{TOP_K}
    SQL
    Chunk.connection.select_all(sql).map do |row|
      { song_id: row["song_id"], match: row["match"].to_f }
    end
  end

  def text_search_song_ids
    Chunk.where("content ILIKE ?", "%#{@query}%").distinct.limit(TOP_K).pluck(:song_id)
  end
end
