class Tag < ApplicationRecord
  has_many :song_tags, dependent: :destroy
  has_many :songs, through: :song_tags

  validates :name, presence: true, uniqueness: true,
    format: { with: /\A[a-zA-Z0-9]+\z/, message: "only allows English letters and digits" }
end
