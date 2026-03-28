class SongSearchService
  TOP_K = 5

  def self.search(query, starting_letter: nil)
    new(query, starting_letter: starting_letter).search
  end

  def self.suggest(query)
    query = query.to_s.strip
    return [] if query.blank?

    song_ids = Chunk.where("content ILIKE ?", "%#{Chunk.sanitize_sql_like(query)}%")
      .select(:song_id).distinct.limit(TOP_K).pluck(:song_id)
    Song.where(id: song_ids).map do |song|
      { id: song.id, pallavi: song.pallavi.to_s.truncate(80), movie: song.movie, start_letter: song.start_letter }
    end
  end

  def initialize(query, starting_letter: nil)
    @query = query.to_s.strip
    @starting_letter = starting_letter
  end

  def search
    return search_by_letter if @starting_letter.present?
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

  def search_by_letter
    Song.where(start_letter: @starting_letter).pluck(:id).map do |id|
      { song_id: id, match: 100.0, top_result: false }
    end
  end

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
