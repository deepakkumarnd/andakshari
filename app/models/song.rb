class Song < ApplicationRecord
  has_many :chunks, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_by_users, through: :likes, source: :user

  before_save :set_start_letter
  after_save :create_chunks, if: -> { saved_change_to_lyrics? || saved_change_to_movie? }

  def cleanup!
    self.lyrics = self.lyrics.strip
    self.movie = self.movie.strip
  end

  def pallavi
    self.lyrics.split("\n")[0..4].join("\n")
  end

  private

  def letter
    lyrics&.strip&.[](0)
  end

  def set_start_letter
    self.start_letter = letter
  end

  def create_chunks
    chunks.destroy_all
    paragraphs = lyrics.split(/\n{2,}/).map(&:strip).reject(&:blank?)
    groups = paragraphs.flat_map { |p| p.split("\n").map(&:strip).reject(&:blank?).each_slice(4).map { |g| g.join("\n") } }
    groups.reject! { |g| g.split.length < 3 }
    return if groups.empty?

    contents = groups.map { |group| "#{group} | #{movie} | #{year}" }
    embeddings = EmbeddingService.embed_many(contents)

    chunk_records = contents.each_with_index.map do |content, i|
      { content: content, embedding: embeddings[i], song_id: id }
    end
    Chunk.insert_all(chunk_records)
  end
end
