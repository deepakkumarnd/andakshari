class Song < ApplicationRecord
  has_many :chunks, dependent: :destroy

  after_save :create_chunks, if: -> { saved_change_to_lyrics? || saved_change_to_movie? }

  def cleanup!
    self.lyrics = self.lyrics.strip
    self.movie = self.movie.strip
  end

  def letter
    lyrics&.strip&.[](0)
  end

  def pallavi
    self.lyrics.split("\n")[0..4].join("\n")
  end

  private

  def create_chunks
    chunks.destroy_all
    lines = lyrics.split("\n").map(&:strip).reject { |l| l.blank? || l.split.length < 3 }
    return if lines.empty?

    contents = lines.map { |line| "#{line} #{movie}" }
    embeddings = EmbeddingService.embed_many(contents)

    chunk_records = contents.each_with_index.map do |content, i|
      { content: content, embedding: embeddings[i], song_id: id }
    end
    Chunk.insert_all(chunk_records)
  end
end
