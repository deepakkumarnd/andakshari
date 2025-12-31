class Letter < ApplicationRecord
    has_many :songs, counter_cache: true

    def cleanup!
        self.letter = self.letter.strip
        self.label_en = self.label_en.strip.downcase
    end
end
