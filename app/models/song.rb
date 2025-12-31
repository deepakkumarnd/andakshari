class Song < ApplicationRecord
  belongs_to :letter

  def cleanup!
    self.lyrics = self.lyrics.strip
    self.movie = self.movie.strip
  end

  def pallavi
    self.lyrics.split("\n")[0..4].join("\n")
  end
end
