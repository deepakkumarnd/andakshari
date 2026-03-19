class Song < ApplicationRecord
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
end
