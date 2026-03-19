class Song < ApplicationRecord
  belongs_to :letter

  before_validation :set_letter_from_lyrics

  def cleanup!
    self.lyrics = self.lyrics.strip
    self.movie = self.movie.strip
  end

  def pallavi
    self.lyrics.split("\n")[0..4].join("\n")
  end

  private

  def set_letter_from_lyrics
    return if lyrics.blank?
    first_char = lyrics.strip[0]
    self.letter = Letter.find_by(letter: first_char)
  end
end
