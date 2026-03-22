class SongSearchService
  TOP_K = 5

  def self.search(query)
    new(query).search
  end

  def initialize(query)
    @query = query.to_s.strip
  end

  def search
    return [] if @query.blank?

    embedding = EmbeddingService.embed_many([ @query ]).first

    vector_results = vector_search(embedding)
    text_results   = text_search_song_ids

    text_song_ids = text_results.map { |r| r[:song_id] }

    merged = (text_results + vector_results)
      .group_by { |r| r[:song_id] }
      .map { |song_id, results| { song_id: song_id, match: results.map { |r| r[:match] }.max, text_match: text_song_ids.include?(song_id) } }
      .sort_by { |r| [ r[:text_match] ? 0 : 1, -r[:match] ] }

    top_match = merged.first&.dig(:match)

    merged.map do |r|
      r.merge(top_result: r[:match] == top_match).except(:text_match)
    end
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
    tsquery = Chunk.sanitize_sql_like(@query).split.map { |w| "'#{w}':*" }.join(" & ")
    sql = <<~SQL
      SELECT song_id,
             ROUND((MAX(ts_rank(to_tsvector('simple', content), to_tsquery('simple', #{Chunk.connection.quote(tsquery)}))) * 100)::numeric, 2) AS match
      FROM chunks
      WHERE to_tsvector('simple', content) @@ to_tsquery('simple', #{Chunk.connection.quote(tsquery)})
      GROUP BY song_id
      ORDER BY match DESC
      LIMIT #{TOP_K}
    SQL
    Chunk.connection.select_all(sql).map do |row|
      { song_id: row["song_id"], match: row["match"].to_f }
    end
  end
end
