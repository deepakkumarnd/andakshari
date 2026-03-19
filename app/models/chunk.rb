class Chunk < ApplicationRecord
  belongs_to :song

  has_neighbors :embedding
end
